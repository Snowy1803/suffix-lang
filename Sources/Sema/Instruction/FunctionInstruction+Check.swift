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
    private func resolve(context: FunctionParsingContext) -> (type: FunctionType, resolver: (FunctionParsingContext) -> ()) {
        let resolved = arguments.resolve(context: context)
        return (type: FunctionType(arguments: resolved.arguments, returning: returning.resolve(context: context)), resolved.resolver)
    }
    
    func createSubContext(parent: FunctionParsingContext) -> FunctionParsingContext {
        // TODO: handle generics (has to be resolved)
        let resolved = resolve(context: parent)
        let function = Function(parent: parent.function, name: name.identifier, type: resolved.type, source: .instruction(self))
        parent.bindings.append(Binding(name: function.name, type: function.type, source: .function(self)))
        let subcontext = FunctionParsingContext(parent: parent, function: function)
        resolved.resolver(subcontext)
        return subcontext
    }
}

extension FunctionTypeReference.Arguments {
    func resolve(context: FunctionParsingContext) -> (arguments: [FunctionType.Argument], resolver: (FunctionParsingContext) -> ()) {
        let resolved = self.arguments.map {
            $0.resolve(context: context)
        }
        let arguments = resolved.flatMap(\.arguments)
        func resolver(context: FunctionParsingContext) {
            resolved.map(\.resolver).forEach { resolver in
                resolver(context)
            }
        }
        return (arguments, resolver(context:))
    }
}

extension FunctionTypeReference.Argument {
    func resolve(context: FunctionParsingContext) -> (arguments: [FunctionType.Argument], resolver: (FunctionParsingContext) -> ()) {
        let inner = self.typeAnnotation?.type.resolve(context: context) ?? AnyType.shared
        switch spec {
        case .count(let int):
            var count = int.integer
            if count < 0 {
                context.typeChecker.diagnostics.append(Diagnostic(token: int.token, message: .negativeArgumentCount(int), severity: .error))
                count = 0
            }
            return (arguments: Array(repeating: FunctionType.Argument(type: inner), count: count), resolver: { context in
                for _ in 0..<count {
                    context.stack.append(StackElement(type: inner, source: .argument(self)))
                }
            })
        case .named(let name):
            return (arguments: [FunctionType.Argument(type: inner, variadic: name.variadic != nil)], resolver: { context in
                // TODO: handle variadics
                context.bindings.append(Binding(name: name.name.identifier, type: inner, source: .argument(self)))
            })
        case .unnamedVariadic(_):
            return (arguments: [FunctionType.Argument(type: inner, variadic: true)], resolver: { context in
                // TODO: make variadic pack
                context.stack.append(StackElement(type: inner, source: .argument(self)))
            })
        }
    }
}

extension FunctionTypeReference.ReturnValues {
    func resolve(context: FunctionParsingContext) -> [FunctionType.Argument] {
        arguments.flatMap { $0.resolve(context: context) }
    }
}

extension FunctionTypeReference.ReturnValue {
    func resolve(context: FunctionParsingContext) -> [FunctionType.Argument] {
        switch spec {
        case .count(let node):
            var count = node.count.integer
            if count < 0 {
                context.typeChecker.diagnostics.append(Diagnostic(token: node.count.token, message: .negativeArgumentCount(node.count), severity: .error))
                count = 0
            }
            return Array(repeating: .init(type: node.typeAnnotation?.type.resolve(context: context) ?? AnyType.shared), count: count)
        case .single(let single):
            return [.init(type: single.resolve(context: context))]
        }
    }
}
