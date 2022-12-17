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

public enum TokenType: Equatable, Hashable {
    /// Insignificant whitespace
    case whitespace
    /// An ignoreable single line comment (starting with `#`)
    case comment
    
    /// A known keyword or contextual keyword
    case keyword(KeywordType)
    
    /// A basic word. Matches `[A-Za-z_/%*+-][A-Za-z0-9_/%*+-]*`
    case word
    /// A number word. Matches `[0-9][0-9_]*`
    case number
    /// A word starting with a number. Matches `[0-9][A-Za-z0-9_/%*+-]*`
    case numberPrefixedWord
    /// A string literal, in double quotes.
    /// Associated data contains the string components
    case stringLiteral

    /// The `.` function call operator
    case dotOperator
    /// The `&` value push operator
    case pushOperator
    /// The `>` identifier binding operator
    case bindOperator
    /// The `:` identifier typing operator
    case typingOperator
    
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
    /// The `;` declaration terminator
    case semicolon
    
    /// The `::` type coercing operator (to be removed)
    case coercingOperator
    /// The `..` token
    case twoDots
    /// Anything unknown, out of normal, errored
    case unresolved
}

public enum KeywordType: String {
    /// Used to define a function
    case `func`
    /// Used to declare a record type
    case record
    /// Used to declare an enum type
    case `enum`
    /// Used to declare a type alias
    case `typealias`
    /// Used to add generic constraints to a declaration
    case `where`
    /// Used to declare a trait
    case `trait`
    /// Used to conform a type to an explicit trait
    case `conform`
}
