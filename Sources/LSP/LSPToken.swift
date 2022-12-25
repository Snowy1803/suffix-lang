//
//  LSPToken.swift
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

struct LSPToken {
    var startPosition: TokenPosition
    var length: Int
    var type: LSPSemanticTokenType
    var modifiers: Modifiers
    
    /// Generates the integer array required by the LSP protocol for sending semantic tokens
    /// - Parameters:
    ///   - line: the line number of the last token. It will be modified with the current automatically
    ///   - character: the character index within the line of the last token. It will be modified with the current automatically
    /// - Returns: An array of 5 integers (delta line, delta char index, length, token type, modifiers)
    func generateData(line: inout Int, character: inout Int) -> [UInt32] {
        let deltaLine: UInt32
        let deltaChar: UInt32
        let startLine = startPosition.line - 1
        let startChar = startPosition.char - 1
        if startLine != line {
            deltaLine = UInt32(startLine - line)
            line = startLine
            character = startChar
            deltaChar = UInt32(character)
        } else {
            deltaLine = 0
            deltaChar = UInt32(startChar - character)
            character = startChar
        }
        let len = UInt32(length)
        return [deltaLine, deltaChar, len, type.index, modifiers.rawValue]
    }
}

extension LSPToken {
    init(tokens: [Token], type: LSPSemanticTokenType, modifiers: Modifiers) {
        self.init(startPosition: tokens.first!.position, length: tokens.last!.endPosition.charInDocument - tokens.first!.position.charInDocument, type: type, modifiers: modifiers)
    }
    
    init?(lexicalToken token: Token) {
        if let type = LSPSemanticTokenType(tokenType: token.type) {
            self.init(startPosition: token.position, length: token.literal.utf16.count, type: type, modifiers: [])
        } else {
            return nil
        }
    }
}

extension LSPToken: Comparable {
    static func < (lhs: LSPToken, rhs: LSPToken) -> Bool {
        lhs.startPosition < rhs.startPosition
    }
    
    static func == (lhs: LSPToken, rhs: LSPToken) -> Bool {
        lhs.startPosition == rhs.startPosition
    }
}
