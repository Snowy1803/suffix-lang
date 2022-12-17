//
//  Block.swift
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

public struct BlockContent: ASTNode {
    public var instructions: [Instruction]
}

public struct Block: ASTNode {
    public var open: Token
    public var content: BlockContent
    public var close: Token
}

public struct RecordBlock: ASTNode {
    public var open: Token
    public var content: [BindInstruction]
    public var close: Token
}

public enum BlockOrSemicolon: ASTEnum {
    case semicolon(Token)
    case block(Block)
    
    public var node: ASTNode {
        switch self {
        case .semicolon(let node as ASTNode),
             .block(let node as ASTNode):
            return node
        }
    }
}
