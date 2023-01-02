//
//  FunctionInstruction+Check.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 06/11/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

extension FunctionInstruction {
    private func resolve(context: ParsingContext, traits: TraitContainer) -> FunctionType {
        let resolved = arguments.resolve(context: context)
        return FunctionType(arguments: resolved, returning: returning.resolve(context: context), traits: traits)
    }
    
    func buildInstruction(context parent: FunctionParsingContext) -> FunctionStmt {
        let partial = PartialFunctionParsingContext(parent: parent)
        let genericArguments = generics?.generics.map { GenericArchetype(name: $0.name.identifier) } ?? []
        partial.types.append(contentsOf: genericArguments)
        let traits = TraitContainer(type: .func, source: true, traits: traits.createContainer(context: parent), diagnostics: &parent.typeChecker.diagnostics)
        let resolved = resolve(context: partial, traits: traits)
        // TODO: remove `source` for FunctionType
        return FunctionStmt(name: name.identifier, generics: genericArguments, functionType: resolved, traits: traits, source: self)
    }
    
}

extension FunctionStmt {
    
    func registerGlobalBindings(parent: FunctionParsingContext) -> TFunction {
        let function = parent.createFunction(name: name, type: type, content: .statement(self), traits: traits)
        parent.add(global: true, binding: TBinding(name: name, type: type, source: .function(source), content: .function(function)))
        return function
    }
    
    func createSubContext(parent: FunctionParsingContext, function: TFunction) -> FunctionParsingContext {
        let subcontext = FunctionParsingContext(parent: parent, function: function)
        subcontext.types.append(contentsOf: function.generics)
        return subcontext
    }
}

extension AnonymousFunctionValue {
    private func resolve(context: ParsingContext, traits: TraitContainer) -> FunctionType {
        let resolved = arguments.resolve(context: context)
        return FunctionType(arguments: resolved, returning: returning.resolve(context: context), traits: traits)
    }
    
    func buildPartialValue(context parent: FunctionParsingContext) -> AnonymousFunctionVal {
        let partial = PartialFunctionParsingContext(parent: parent)
        let traits = TraitContainer(type: .func, source: true, traits: traits.createContainer(context: parent), diagnostics: &parent.typeChecker.diagnostics)
        let resolved = resolve(context: partial, traits: traits)
        return AnonymousFunctionVal(type: resolved, source: self, traits: traits)
    }
}

extension AnonymousFunctionVal {
    func createAnonymousFunctionContext(parent: FunctionParsingContext) -> FunctionParsingContext {
        let function = parent.createFunction(name: "anonymous function", type: type, content: .anonymous(self), traits: traits)
        let subcontext = FunctionParsingContext(parent: parent, function: function)
        return subcontext
    }
}

extension FunctionTypeReference.Arguments {
    func resolve(context: ParsingContext) -> [FunctionType.Argument] {
        arguments.flatMap { $0.resolveArgument(context: context) }
    }
    
    func registerLocalBindings(subcontext: FunctionParsingContext) {
        arguments.forEach {
            $0.registerLocalBindings(context: subcontext)
        }
    }
}

extension FunctionTypeReference.Argument {
    func resolveArgument(context: ParsingContext) -> [FunctionType.Argument] {
        switch spec {
        case .count(let int):
            var count = int.count.integer
            if count < 0 {
                context.typeChecker.diagnostics.append(Diagnostic(tokens: int.count.tokens, message: .negativeArgumentCount(int.count), severity: .error))
                count = 0
            }
            return Array(repeating: FunctionType.Argument(type: int.typeAnnotation.type.resolve(context: context)), count: count)
        case .named(let name):
            return [FunctionType.Argument(type: name.typeAnnotation.type.resolve(context: context), variadic: name.variadic != nil)]
        case .unnamedVariadic(let variadic):
            return [FunctionType.Argument(type: variadic.typeAnnotation.type.resolve(context: context), variadic: true)]
        case .unnamedSingle(let type):
            return [FunctionType.Argument(type: type.resolve(context: context))]
        }
    }
    
    func registerLocalBindings(context: FunctionParsingContext) {
        switch spec {
        case .count(let int):
            var count = int.count.integer
            if count < 0 {
                count = 0
            }
            let inner = int.typeAnnotation.type.resolve(context: context)
            for _ in 0..<count {
                let element = TStackElement(value: .argument(ArgumentVal(function: context.function, index: context.function.arguments.count, type: inner, source: self)), source: .argument(self))
                context.stack.append(element)
                context.function.arguments.append(.stack(element))
            }
        case .named(let name):
            let inner = name.typeAnnotation.type.resolve(context: context)
            // TODO: handle variadics
            let binding = TBinding(name: name.name.identifier, type: inner, source: .argument(self), content: .argument(ArgumentVal(function: context.function, index: context.function.arguments.count, type: inner, source: self)))
            context.add(global: true, binding: binding)
            context.function.arguments.append(.binding(binding))
        case .unnamedVariadic(let variadic):
            let inner = variadic.typeAnnotation.type.resolve(context: context)
            // TODO: make variadic pack
            let element = TStackElement(value: .argument(ArgumentVal(function: context.function, index: context.function.arguments.count, type: inner, source: self)), source: .argument(self))
            context.stack.append(element)
            context.function.arguments.append(.stack(element))
        case .unnamedSingle(let type):
            let inner = type.resolve(context: context)
            let element = TStackElement(value: .argument(ArgumentVal(function: context.function, index: context.function.arguments.count, type: inner, source: self)), source: .argument(self))
            context.stack.append(element)
            context.function.arguments.append(.stack(element))
        }
    }
}

extension FunctionTypeReference.ReturnValues {
    func resolve(context: ParsingContext) -> [FunctionType.Argument] {
        arguments.flatMap { $0.resolve(context: context) }
    }
}

extension FunctionTypeReference.ReturnValue {
    func resolve(context: ParsingContext) -> [FunctionType.Argument] {
        switch spec {
        case .count(let node):
            var count = node.count.integer
            if count < 0 {
                context.typeChecker.diagnostics.append(Diagnostic(tokens: node.count.tokens, message: .negativeArgumentCount(node.count), severity: .error))
                count = 0
            }
            return Array(repeating: .init(type: node.typeAnnotation?.type.resolve(context: context) ?? AnyType.shared), count: count)
        case .single(let single):
            return [.init(type: single.resolve(context: context))]
        }
    }
}

extension TraitCollection {
    func createContainer(context: ParsingContext) -> [TraitContainer.TraitInfo] {
        self.traits.map(\.trait).createContainer(context: context)
    }
}

extension GenericTraitsArgument {
    func createContainer(context: ParsingContext) -> [TraitContainer.TraitInfo] {
        self.traits.map(\.trait).createContainer(context: context)
    }
}

private extension Array<TraitReference> {
    func createContainer(context: ParsingContext) -> [TraitContainer.TraitInfo] {
        self.compactMap { ref in
            guard let trait = context.getTrait(name: ref.name.identifier) else {
                context.typeChecker.diagnostics.append(Diagnostic(tokens: ref.name.tokens, message: .unknownTrait(ref.name.identifier), severity: .error))
                return nil
            }
            // TODO: parameterize trait with generics (generic map stuff)
            return TraitContainer.TraitInfo(trait: trait, source: .explicit(ref))
        }
    }
}
