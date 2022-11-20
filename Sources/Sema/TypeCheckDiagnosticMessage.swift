//
//  TypeCheckDiagnosticMessage.swift
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

extension Diagnostic {
    init(token: Token, message: TypeCheckDiagnosticMessage, severity: Severity, hints: [Diagnostic] = []) {
        self.init(token: token, message: message as DiagnosticMessage, severity: severity, hints: hints)
    }
    
    init(tokens: [Token], message: TypeCheckDiagnosticMessage, severity: Severity, hints: [Diagnostic] = []) {
        self.init(tokens: tokens, message: message as DiagnosticMessage, severity: severity, hints: hints)
    }
}

enum TypeCheckDiagnosticMessage: DiagnosticMessage {
    case negativeArgumentCount(IntegerValue)
    case unknownType(String)
    case missingTypeAnnotation
    case poppingEmptyStack
    case invalidStringEscapeSequence(Substring)
    case noViableBinding(String)
    case callNonCallable(String, SType)
    case returningTooMuch(expected: [SType], actual: [SType])
    case returnMissing(expected: [SType], actual: [SType])
    case returningFromMain
    case hintReturnHere(SType)
    
    var description: String {
        switch self {
        case .negativeArgumentCount(let token):
            return "Invalid argument multiplier: \(token.integer) is negative"
        case .unknownType(let name):
            return "Could not find type '\(name)' in scope"
        case .missingTypeAnnotation:
            return "Missing type annotation"
        case .poppingEmptyStack:
            return "Cannot pop more values than there is on the stack"
        case .invalidStringEscapeSequence(let str):
            return "Unknown escape sequence '\(str)' in string"
        case .noViableBinding(let str):
            return "Could not find a viable binding named '\(str)'"
        case .callNonCallable(let str, let type):
            return "Cannot call value '\(str)' of non-function type '\(type)'"
        case .returningTooMuch(expected: let expected, actual: let actual):
            return "Returning too many values: expected to get (\(expected.map(\.description).joined(separator: ", "))) but found  (\(actual.map(\.description).joined(separator: ", ")))"
        case .returnMissing(expected: let expected, actual: let actual):
            return "Missing return values: expected to get (\(expected.map(\.description).joined(separator: ", "))) but found  (\(actual.map(\.description).joined(separator: ", ")))"
        case .returningFromMain:
            return "Unused value in main function"
        case .hintReturnHere(let type):
            return "Value of type '\(type)' returned here"
        }
    }
}
