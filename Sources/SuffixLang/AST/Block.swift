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

struct Block: ASTNode {
    var open: Token
    var content: BlockContent
    var close: Token
    
    var nodeChildren: [ASTElement] {
        [ASTElement(name: "content", value: content)]
    }
}

struct BlockContent: ASTNode {
    var instructions: [Instruction]
    
    var nodeChildren: [ASTElement] {
        [ASTElement(name: "instructions", value: instructions.map(\.node))]
    }
}
