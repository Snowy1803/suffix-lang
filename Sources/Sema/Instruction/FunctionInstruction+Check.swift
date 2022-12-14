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
    private func resolve(context: ParsingContext, generics: [GenericArchetype]) -> FunctionType {
        let resolved = arguments.resolve(context: context)
        return FunctionType(generics: generics, arguments: resolved, returning: returning.resolve(context: context))
    }
    
    func registerGlobalBindings(parent: FunctionParsingContext) {
        let partial = PartialFunctionParsingContext(parent: parent)
        let genericArguments = generics?.generics.map { GenericArchetype(name: $0.name.identifier) } ?? []
        partial.types.append(contentsOf: genericArguments)
        let resolved = resolve(context: partial, generics: genericArguments)
        let function = parent.createFunction(name: name.identifier, type: resolved, source: .instruction(self), traits: TraitContainer(type: .func, traits: traits.createContainer(context: parent), diagnostics: &parent.typeChecker.diagnostics))
        parent.registeredFunctions[ObjectID(self)] = function
        parent.bindings.append(Binding(name: function.name, type: function.type, source: .function(self), ref: .function(function)))
    }
    
    func createSubContext(parent: FunctionParsingContext) -> FunctionParsingContext {
        guard let function = parent.registeredFunctions[ObjectID(self)] else {
            preconditionFailure()
        }
        let subcontext = FunctionParsingContext(parent: parent, function: function)
        subcontext.types.append(contentsOf: function.type.generics)
        return subcontext
    }
    
    func registerLocalBindings(subcontext: FunctionParsingContext) {
        arguments.arguments.forEach {
            $0.registerLocalBindings(context: subcontext)
        }
    }
}

extension AnonymousFunctionValue {
    private func resolve(context: ParsingContext, generics: [GenericArchetype]) -> FunctionType {
        let resolved = arguments.resolve(context: context)
        return FunctionType(generics: generics, arguments: resolved, returning: returning.resolve(context: context))
    }
    
    func createAnonymousFunctionContext(parent: FunctionParsingContext) -> FunctionParsingContext {
        let partial = PartialFunctionParsingContext(parent: parent)
        let genericArguments = generics?.generics.map { GenericArchetype(name: $0.name.identifier) } ?? []
        partial.types.append(contentsOf: genericArguments)
        let resolved = resolve(context: partial, generics: genericArguments)
        let function = parent.createFunction(name: "anonymous function", type: resolved, source: .anonymous(self), traits: TraitContainer(type: .func, traits: traits.createContainer(context: parent), diagnostics: &parent.typeChecker.diagnostics))
        let subcontext = FunctionParsingContext(parent: parent, function: function)
        subcontext.types.append(contentsOf: function.type.generics)
        return subcontext
    }
    
    func registerLocalBindings(subcontext: FunctionParsingContext) {
        arguments.arguments.forEach {
            $0.registerLocalBindings(context: subcontext)
        }
    }
}

extension FunctionTypeReference.Arguments {
    func resolve(context: ParsingContext) -> [FunctionType.Argument] {
        arguments.flatMap { $0.resolveArgument(context: context) }
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
                let ref = LocalRef(givenName: "", type: inner)
                context.function.arguments.append(ref)
                context.stack.append(StackElement(type: inner, source: .argument(self), ref: .local(ref)))
            }
        case .named(let name):
            let inner = name.typeAnnotation.type.resolve(context: context)
            // TODO: handle variadics
            let ref = LocalRef(givenName: name.name.identifier, type: inner)
            context.function.arguments.append(ref)
            context.bindings.append(Binding(name: name.name.identifier, type: inner, source: .argument(self), ref: .local(ref)))
        case .unnamedVariadic(let variadic):
            let inner = variadic.typeAnnotation.type.resolve(context: context)
            // TODO: make variadic pack
            let ref = LocalRef(givenName: "", type: inner)
            context.function.arguments.append(ref)
            context.stack.append(StackElement(type: inner, source: .argument(self), ref: .local(ref)))
        case .unnamedSingle(let type):
            let inner = type.resolve(context: context)
            let ref = LocalRef(givenName: "", type: inner)
            context.function.arguments.append(ref)
            context.stack.append(StackElement(type: inner, source: .argument(self), ref: .local(ref)))
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
        self.traits.map(\.trait).compactMap { ref in
            guard let trait = context.getTrait(name: ref.name.identifier) else {
                context.typeChecker.diagnostics.append(Diagnostic(tokens: ref.name.tokens, message: .unknownTrait(ref.name.identifier), severity: .error))
                return nil
            }
            // TODO: parameterize trait with generics (generic map stuff)
            return TraitContainer.TraitInfo(trait: trait, source: .explicit(ref))
        }
    }
}
