//
//  TokenPosition.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 22/10/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public struct TokenPosition {
    /// A 1-indexed line number
    public var line: Int = 1
    
    /// The UTF-16, 1-indexed, character number in the line
    public var char: Int = 1
    
    /// The UTF-16, 1-indexed, character number in the document
    public var charInDocument: Int = 1
    
    /// The index in the document, used for the cursor internally
    var index: String.Index
    var lineStart: String.Index
    
    init(index: String.Index) {
        self.index = index
        self.lineStart = index
    }
    
    public var isValid: Bool {
        line > 0 && char > 0
    }
    
    public func getFullLine(document: String) -> Substring {
        var lineEnd = self
        while index < document.endIndex && line == lineEnd.line {
            lineEnd.nextChar(document: document)
        }
        return document[lineStart..<lineEnd.index]
    }
    
    mutating func nextChar(document: String) {
        let prev = index
        index = document.index(after: index)
        let diff = index.utf16Offset(in: document) - prev.utf16Offset(in: document)
        if document[prev].isNewline {
            line += 1
            char = 1
            lineStart = index
        } else {
            char += diff
        }
        charInDocument += diff
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

internal extension TokenPosition {
    static let missing = {
        var pos = TokenPosition(index: "".startIndex)
        pos.line = -1
        pos.char = -1
        pos.charInDocument = -1
        return pos
    }()
}

extension TokenPosition: Comparable {
    public static func < (lhs: TokenPosition, rhs: TokenPosition) -> Bool {
        lhs.index < rhs.index
    }
}
