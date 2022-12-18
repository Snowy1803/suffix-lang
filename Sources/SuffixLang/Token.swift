//
//  Token.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 21/10/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public struct Token {
    /// The position, for diagnostics
    public var position: TokenPosition
    
    /// The substring inside the document
    public var literal: Substring
    
    /// The type of this token
    public var type: TokenType
    
    /// The type of this token
    public var data: AssociatedData?
}

extension Token: Equatable {
    public static func == (lhs: Token, rhs: Token) -> Bool {
        lhs.literal.startIndex == rhs.literal.startIndex && lhs.literal.base == rhs.literal.base
    }
}

extension Token {
    public var endPosition: TokenPosition {
        var pos = position
        pos.advance(to: literal.endIndex, in: literal.base)
        return pos
    }
}

extension Token {
    public enum AssociatedData {
        case interpolation([StringComponent])
    }
}

extension Token {
    public enum StringComponent: Equatable {
        /// Literal text
        case literal(Substring)
        /// An escaped char, such as `\n`. Always starts with `\`
        case escaped(Substring)
        /// A percent encoded interpolation, such as `%.2f`. Always starts with `%`.
        case percent(Substring)
        
        var substring: Substring {
            get {
                switch self {
                case .literal(let value), .escaped(let value), .percent(let value):
                    return value
                }
            }
            set {
                switch self {
                case .literal:
                    self = .literal(newValue)
                case .escaped:
                    self = .escaped(newValue)
                case .percent:
                    self = .percent(newValue)
                }
            }
        }
        
        public var popCount: Int {
            switch self {
            case .literal, .escaped:
                return 0
            case .percent:
                return 1
            }
        }
    }
}
