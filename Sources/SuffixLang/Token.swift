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

extension Token {
    public enum AssociatedData {
        case identifier(String)
        case int(Int)
        case float(Double)
        case interpolation([StringComponent])
    }
}

extension Token {
    public enum StringComponent {
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
                case .literal(_):
                    self = .literal(newValue)
                case .escaped(_):
                    self = .escaped(newValue)
                case .percent(_):
                    self = .percent(newValue)
                }
            }
        }
    }
}

extension Token {
    static func onePastEnd(document: String) -> Token {
        Token(position: .missing, literal: document[document.endIndex..<document.endIndex], type: .unresolved)
    }
}
