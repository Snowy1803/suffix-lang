//
//  LSPSemanticTokenType.swift
//  SuffixLang LSP
// 
//  Created by Emil Pedersen on 25/09/2021.
//  Copyright © 2020 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

/// The equivalent of GRPHLexer.TokenType, but only containing LSP Semantic Token types
enum LSPSemanticTokenType: UInt32, CaseIterable {
    /// A simple or documentation comment
    case comment
    
    /// A binding name
    case variable
    /// A binding name with a function type
    case function
    /// A type name
    case type
    /// A binding with an enum case as its source
    case enumMember
    /// A binding with a parameter as its source
    case parameter
    /// A binding with a property accessor as its source
    case property
    
    /// A keyword
    case keyword
    /// An integer or a float
    case number
    /// A quoted string literal
    case string
    
    /// Any operator (& . >)
    case `operator`
    
    var name: String {
        String(describing: self)
    }
    
    var index: UInt32 {
        rawValue
    }
}

extension LSPSemanticTokenType {
    /// Transforms a non-semantic token into an LSP semantic tokens. Returns nil if it needs more context or if there should be no semantic token
    init?(tokenType: TokenType) {
        switch tokenType {
        case .comment:
            self = .comment
        case .stringLiteral:
            self = .string
        case .dotOperator, .bindOperator, .pushOperator, .typingOperator:
            self = .operator
        case .whitespace, .comma, .curlyOpen, .curlyClose, .coercingOperator, .semicolon, .bracketOpen, .bracketClose, .parenOpen, .parenClose, .unresolved, .variadic, .twoDots:
            return nil
        case .keyword, .word, .number, .numberPrefixedWord:
            return nil // needs more context
        }
    }
}
