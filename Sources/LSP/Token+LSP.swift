//
//  Token+LSP.swift
//  SuffixLang LSP
// 
//  Created by Emil Pedersen on 24/09/2021.
//  Copyright © 2020 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang
import LanguageServerProtocol

extension Token {
    var lspStartPos: Position {
        position.lsp
    }
    
    var lspEndPos: Position {
        endPosition.lsp
    }
    
    var positionRange: Range<Position> {
        lspStartPos..<lspEndPos
    }
    
//    var positionRangeClosed: ClosedRange<Position> {
//        lspStartPos...lspEndPos
//    }
}

extension TokenPosition {
    var lsp: Position {
        Position(line: line - 1, utf16index: char - 1)
    }
}

//extension SemanticToken.Modifiers {
//    static let legend = [
//        "declaration",
//        "definition",
//        "readonly",
//        "deprecated",
//        "modification",
//        "documentation",
//        "defaultLibrary",
//    ]
//}
