//
//  Diagnostic.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 23/10/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public struct Diagnostic {
    public var token: Token
    public var message: DiagnosticMessage
    public var severity: Severity
    public var hints: [Diagnostic]
    
    public init(token: Token, message: DiagnosticMessage, severity: Severity, hints: [Diagnostic] = []) {
        self.token = token
        self.message = message
        self.severity = severity
        self.hints = hints
    }
    
    public enum Severity: Comparable {
        /// A hint, usually attached to another diagnostic
        case hint
        /// An information about an unimportant problem
        case info
        /// A warning that may want to be fixed for the program to behave correctly
        case warning
        /// An error that makes the program invalid, but can be recovered from automatically
        case error
        /// An error that makes the program invalid, and can't be recovered from
        case fatal
    }
}

public protocol DiagnosticMessage: CustomStringConvertible {
    
}

enum ParserDiagnosticMessage: DiagnosticMessage {
    case expectedToken(literal: String)
    case expectedTokenType(TokenType)
    case expectedNode(Any.Type)
    case invalidToken
    
    var description: String {
        switch self {
        case .expectedToken(literal: let literal):
            return "Expected token '\(literal)'"
        case .expectedTokenType(let type):
            return "Expected \(type)"
        case .expectedNode(let type):
            return "Expected \(type)"
        case .invalidToken:
            return "Invalid token"
        }
    }
}
