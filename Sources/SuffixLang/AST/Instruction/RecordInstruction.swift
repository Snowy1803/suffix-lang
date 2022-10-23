//
//  RecordInstruction.swift
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

struct RecordInstruction: ASTNode {
    var keyword: Token
    var name: Token
    var block: RecordBlock
    
    var nodeData: String? {
        if case .identifier(let id) = name.data {
            return id
        }
        return nil
    }
    
    var nodeChildren: [ASTElement] {
        [ASTElement(name: "block", value: [block])]
    }
}
