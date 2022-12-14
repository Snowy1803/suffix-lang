//
//  EnumInstruction.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 10/12/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public class EnumInstruction: ASTNode {
    public let keyword: Token
    public let name: Identifier
    public let block: RecordBlock
    
    init(keyword: Token, name: Identifier, block: RecordBlock) {
        self.keyword = keyword
        self.name = name
        self.block = block
    }
}
