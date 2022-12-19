//
//  SemaLogCollector.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 18/12/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Sema

class SemaLogCollector: LoggerDestination {
    var lexicalTokens: [LSPToken]
    var semanticTokens: [LSPToken] = []
    
    init(lexicalTokens: [LSPToken]) {
        self.lexicalTokens = lexicalTokens
    }
    
    func add(token: LSPToken) {
        lexicalTokens.removeAll(where: { lex in
            let a = lex.startPosition.charInDocument
            let b = token.startPosition.charInDocument
            let c = token.startPosition.charInDocument + lex.length
            let d = lex.startPosition.charInDocument + lex.length
            return a <= b && c <= d
        })
        semanticTokens.append(token)
    }
    
    func createSemanticToken(binding: Binding) {
        switch binding.source {
        case .builtin, .recordConstructor:
            break
        case .binding(let bindInstruction):
            add(token: LSPToken(tokens: bindInstruction.value.literal.tokens, type: .variable))
        case .argument(let argument):
            switch argument.spec {
            case .count, .unnamedVariadic, .unnamedSingle:
                break // impossible
            case .named(let named):
                add(token: LSPToken(tokens: named.name.tokens, type: .parameter))
            }
        case .function(let functionInstruction):
            add(token: LSPToken(tokens: functionInstruction.name.tokens, type: .function))
        case .recordFieldAccessor(_, _, let bindInstruction):
            add(token: LSPToken(tokens: bindInstruction.value.literal.tokens, type: .property))
        case .enumCase(_, _, let bindInstruction):
            add(token: LSPToken(tokens: bindInstruction.value.literal.tokens, type: .enumMember))
        }
    }
    
    func getType(binding: Binding) -> LSPSemanticTokenType {
        switch binding.source {
        case .builtin:
            switch binding.type {
            case is FunctionType:
                return .function
            case is EnumType:
                return .enumMember // bool
            default:
                return .variable
            }
        case .recordConstructor:
            return .function // maybe something else ?
        case .binding:
            return .variable
        case .argument:
            return .parameter
        case .function:
            return .function
        case .recordFieldAccessor:
            return .property
        case .enumCase:
            return .enumMember
        }
    }
    
    func getType(type: NamedType) -> LSPSemanticTokenType {
        switch type {
        case is AnyType:
            return .keyword
        case is RecordType:
            return .struct
        case is EnumType:
            return .enum
        case is GenericArchetype:
            return .typeParameter
        default:
            return .type
        }
    }
    
    func log(_ event: LogEvent) {
        switch event {
        case .globalBindingCreated(let binding, let function):
            createSemanticToken(binding: binding)
        case .localBindingCreated(let binding, let function):
            createSemanticToken(binding: binding)
        case .funcCreated(let function):
            switch function.source {
            case .instruction(let functionInstruction):
                add(token: LSPToken(tokens: [functionInstruction.keyword], type: .keyword))
                for generic in functionInstruction.generics?.generics ?? [] {
                    add(token: LSPToken(tokens: generic.name.tokens, type: .typeParameter))
                }
                for trait in functionInstruction.traits.traits {
                    add(token: LSPToken(tokens: trait.trait.name.tokens, type: .interface))
                }
            case .anonymous:
                break // idk
            case .main, .builtin, .synthesized:
                break
            }
        case .enumCreated(let enumType):
            switch enumType.source {
            case .instruction(let enumInstruction):
                add(token: LSPToken(tokens: [enumInstruction.keyword], type: .keyword))
                add(token: LSPToken(tokens: enumInstruction.name.tokens, type: .enum))
            case .builtin:
                break
            }
        case .recordCreated(let recordType):
            switch recordType.source {
            case .instruction(let recordInstruction):
                add(token: LSPToken(tokens: [recordInstruction.keyword], type: .keyword))
                add(token: LSPToken(tokens: recordInstruction.name.tokens, type: .struct))
            case .builtin:
                break
            }
        case .bindingReferenced(let binding, let referenceValue):
            add(token: LSPToken(tokens: referenceValue.identifier.literal.tokens, type: getType(binding: binding)))
        case .namedTypeReferenced(let type, let reference):
            add(token: LSPToken(tokens: reference.name.tokens, type: getType(type: type)))
        case .functionTypeReferenced(_, let reference):
            for trait in reference.traits?.traits ?? [] {
                add(token: LSPToken(tokens: trait.trait.name.tokens, type: .interface))
            }
        }
    }
}
