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
import SuffixLang
import Sema
import LanguageServerProtocol

class SemaLogCollector: LoggerDestination {
    var lexicalTokens: [LSPToken]
    var semanticTokens: [LSPToken] = []
    var scopedBindings: [ScopedBinding] = []
    
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
            // TODO: deprecated
            add(token: LSPToken(tokens: bindInstruction.value.literal.tokens, type: .variable, modifiers: [.declaration, .definition]))
        case .argument(let argument):
            switch argument.spec {
            case .count, .unnamedVariadic, .unnamedSingle:
                break // impossible
            case .named(let named):
                add(token: LSPToken(tokens: named.name.tokens, type: .parameter, modifiers: [.declaration, .definition]))
            }
        case .function(let functionInstruction):
            add(token: LSPToken(tokens: functionInstruction.name.tokens, type: .function, modifiers: [.declaration, (functionInstruction.block.isSemicolon ? .definition : [])]))
        case .recordFieldAccessor(_, _, let bindInstruction):
            // TODO: deprecated
            add(token: LSPToken(tokens: bindInstruction.value.literal.tokens, type: .property, modifiers: [.declaration, .definition]))
        case .enumCase(_, _, let bindInstruction):
            // TODO: deprecated
            add(token: LSPToken(tokens: bindInstruction.value.literal.tokens, type: .enumMember, modifiers: [.declaration, .definition]))
        }
    }
    
    func log(_ event: LogEvent) {
        switch event {
        case .globalBindingCreated(let binding, let function):
            createSemanticToken(binding: binding)
            if case .instruction(let node) = function?.source,
               case .block(let block) = node.block {
                scopedBindings.append(ScopedBinding(start: block.open.endPosition, end: block.close.position, binding: binding))
            } else {
                scopedBindings.append(ScopedBinding(start: nil, end: nil, binding: binding))
            }
        case .localBindingCreated(let binding, let function):
            createSemanticToken(binding: binding)
            if case .binding(let source) = binding.source {
                let start = source.op.position
                if case .instruction(let node) = function.source,
                   case .block(let block) = node.block {
                    scopedBindings.append(ScopedBinding(start: start, end: block.close.position, binding: binding))
                } else {
                    scopedBindings.append(ScopedBinding(start: start, end: nil, binding: binding))
                }
            } else {
                print("local binding created but source isn't a `>`")
            }
        case .funcCreated(let function):
            switch function.source {
            case .instruction(let functionInstruction):
                add(token: LSPToken(tokens: [functionInstruction.keyword], type: .keyword, modifiers: []))
                for generic in functionInstruction.generics?.generics ?? [] {
                    add(token: LSPToken(tokens: generic.name.tokens, type: .typeParameter, modifiers: [.declaration]))
                }
                for trait in functionInstruction.traits.traits {
                    add(token: LSPToken(tokens: trait.trait.name.tokens, type: .interface, modifiers: []))
                }
            case .anonymous:
                break // idk
            case .main, .builtin, .synthesized:
                break
            }
        case .enumCreated(let enumType):
            switch enumType.source {
            case .instruction(let enumInstruction):
                add(token: LSPToken(tokens: [enumInstruction.keyword], type: .keyword, modifiers: []))
                add(token: LSPToken(tokens: enumInstruction.name.tokens, type: .enum, modifiers: [.declaration, .definition]))
            case .builtin:
                break
            }
        case .recordCreated(let recordType):
            switch recordType.source {
            case .instruction(let recordInstruction):
                add(token: LSPToken(tokens: [recordInstruction.keyword], type: .keyword, modifiers: []))
                add(token: LSPToken(tokens: recordInstruction.name.tokens, type: .struct, modifiers: [.declaration, .definition]))
            case .builtin:
                break
            }
        case .bindingReferenced(let binding, let referenceValue):
            add(token: LSPToken(tokens: referenceValue.identifier.literal.tokens, type: binding.semanticTokenType, modifiers: binding.semanticModifiers))
        case .namedTypeReferenced(let type, let reference):
            add(token: LSPToken(tokens: reference.name.tokens, type: type.semanticTokenType, modifiers: type.semanticModifiers))
        case .functionTypeReferenced(_, let reference):
            for trait in reference.traits?.traits ?? [] {
                // TODO: trait source
                add(token: LSPToken(tokens: trait.trait.name.tokens, type: .interface, modifiers: [.defaultLibrary]))
            }
        }
    }
}

extension NamedType {
    var semanticTokenType: LSPSemanticTokenType {
        switch self {
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
    
    var semanticModifiers: LSPToken.Modifiers {
        // TODO: add deprecated
        let defaultLibrary: LSPToken.Modifiers = {
            switch self {
            case let type as EnumType:
                switch type.source {
                case .builtin:
                    return .defaultLibrary
                case .instruction:
                    return []
                }
            case let type as RecordType:
                switch type.source {
                case .builtin:
                    return .defaultLibrary
                case .instruction:
                    return []
                }
            default:
                return .defaultLibrary
            }
        }()
        return [defaultLibrary]
    }
}

extension Binding {
    var semanticTokenType: LSPSemanticTokenType {
        switch source {
        case .builtin:
            switch type {
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
    
    var semanticModifiers: LSPToken.Modifiers {
        // TODO: add deprecated
        let defaultLibrary: LSPToken.Modifiers = {
            switch source {
            case .builtin:
                return .defaultLibrary
            default:
                return []
            }
        }()
        return [defaultLibrary]
    }
    
    var completionKind: CompletionItemKind {
        switch source {
        case .builtin:
            switch type {
            case is FunctionType:
                return .function
            case is EnumType:
                return .enumMember // bool
            default:
                return .variable
            }
        case .recordConstructor:
            return .constructor
        case .binding:
            return .variable
        case .argument:
            return .variable
        case .function:
            return .function
        case .recordFieldAccessor:
            return .property
        case .enumCase:
            return .enumMember
        }
    }
}
