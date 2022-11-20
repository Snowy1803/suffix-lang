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
    var tokens: [Token]
    public var message: DiagnosticMessage
    public var severity: Severity
    public var hints: [Diagnostic]
    
    public init(token: Token, message: DiagnosticMessage, severity: Severity, hints: [Diagnostic] = []) {
        self.init(tokens: [token], message: message, severity: severity, hints: hints)
    }
    
    public init(tokens: [Token], message: DiagnosticMessage, severity: Severity, hints: [Diagnostic] = []) {
        let tokens = tokens.filter { $0.position.isValid }
        assert(tokens.count >= 0)
        self.tokens = tokens
        self.message = message
        self.severity = severity
        self.hints = hints
    }
    
    public var document: String {
        tokens[0].literal.base
    }
    
    public var startPosition: TokenPosition {
        tokens[0].position
    }
    
    public var endPosition: TokenPosition {
        var pos = startPosition
        pos.advance(to: tokens.last!.literal.endIndex, in: document)
        return pos
    }
    
    public var literal: Substring {
        document[startPosition.index..<endPosition.index]
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
