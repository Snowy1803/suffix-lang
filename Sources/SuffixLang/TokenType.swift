//
//  TokenType.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 20/10/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public enum TokenType {
    /// Insignificant whitespace
    case whitespace
    /// An ignoreable single line comment (starting with `#`)
    case comment
    
    /// A keyword: `func` or `record`
    case keyword
    /// An identifier. Matches `[ A-Za-z_/%*+-][ A-Za-z0-9_/%*+-]*`
    /// Associated data is the canonical identifier string
    case identifier
    /// An integer literal. Matches `[0-9][0-9 _]*`
    /// Associated data is the integer value
    case integerLiteral
    /// A float literal. Matches `[0-9][0-9 _]*(,[0-9 _]*)?(f|F)?`
    /// Associated data is the float value
    case floatLiteral
    /// A string literal, in double quotes.
    /// Associated data is the string value
    case stringLiteral

    /// The `.` function call operator
    case dotOperator
    /// The `&` value push operator
    case pushOperator
    /// The `>` identifier binding operator
    case bindOperator
    /// The `:` identifier typing operator
    case typingOperator
    /// The `::` type coercing operator
    case coercingOperator
    
    /// The `{` token, used for function definitions
    case curlyOpen
    /// The `}` token
    case curlyClose
    /// The `(` token, used for parameter specifications
    case parenOpen
    /// The `)` token
    case parenClose
    /// The `[` token, used for generic types
    case bracketOpen
    /// The `]` token
    case bracketClose
    /// The `,` token
    case comma
    /// The `...` token
    case variadic
    
    /// The `..` token
    case twoDots
    /// Anything unknown, out of normal, errored
    case unresolved
}
