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
    
    public enum AssociatedData {
        case string(String)
        case int(Int)
        case float(Double)
    }
}

public struct TokenPosition {
    /// A 1-indexed line number
    public var line: Int = 1
    
    /// The UTF-16, 1-indexed, character number
    public var char: Int = 1
    
    /// The UTF-16, 1-indexed, character number
    public var index: String.Index
    
    mutating func nextChar(document: String) {
        let prev = index
        index = document.index(after: index)
        if document[prev].isNewline {
            line += 1
            char = 1
        } else {
            char += index.utf16Offset(in: document) - prev.utf16Offset(in: document)
        }
    }
    
    mutating func advance(to dest: String.Index, in document: String) {
        while index != dest {
            nextChar(document: document)
        }
    }
    
    mutating func advance(by amount: Int, in document: String) {
        for _ in 0..<amount {
            nextChar(document: document)
        }
    }
}
