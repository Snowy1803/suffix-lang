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
    var semanticTokens: [LSPToken] = []
    
    func createSemanticToken(binding: Binding) {
        switch binding.source {
        case .builtin, .recordConstructor:
            break
        case .binding(let bindInstruction):
            semanticTokens.append(LSPToken(tokens: bindInstruction.value.literal.tokens, type: .variable))
        case .argument(let argument):
            switch argument.spec {
            case .count, .unnamedVariadic, .unnamedSingle:
                break // impossible
            case .named(let named):
                semanticTokens.append(LSPToken(tokens: named.name.tokens, type: .parameter))
            }
        case .function(let functionInstruction):
            semanticTokens.append(LSPToken(tokens: functionInstruction.name.tokens, type: .function))
        case .recordFieldAccessor(_, _, let bindInstruction):
            semanticTokens.append(LSPToken(tokens: bindInstruction.value.literal.tokens, type: .property))
        case .enumCase(_, _, let bindInstruction):
            semanticTokens.append(LSPToken(tokens: bindInstruction.value.literal.tokens, type: .enumMember))
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
    
    func log(_ event: LogEvent) {
        switch event {
        case .globalBindingCreated(let binding, let function):
            createSemanticToken(binding: binding)
        case .localBindingCreated(let binding, let function):
            createSemanticToken(binding: binding)
        case .funcCreated(let function):
            switch function.source {
            case .instruction(let functionInstruction):
                semanticTokens.append(LSPToken(tokens: [functionInstruction.keyword], type: .keyword))
            case .anonymous:
                break // idk
            case .main, .builtin, .synthesized:
                break
            }
        case .enumCreated(let enumType):
            switch enumType.source {
            case .instruction(let enumInstruction):
                semanticTokens.append(LSPToken(tokens: [enumInstruction.keyword], type: .keyword))
                semanticTokens.append(LSPToken(tokens: enumInstruction.name.tokens, type: .enum))
            case .builtin:
                break
            }
        case .recordCreated(let recordType):
            switch recordType.source {
            case .instruction(let recordInstruction):
                semanticTokens.append(LSPToken(tokens: [recordInstruction.keyword], type: .keyword))
                semanticTokens.append(LSPToken(tokens: recordInstruction.name.tokens, type: .struct))
            case .builtin:
                break
            }
        case .bindingReferenced(let binding, let referenceValue):
            semanticTokens.append(LSPToken(tokens: referenceValue.identifier.literal.tokens, type: getType(binding: binding)))
        }
    }
}
