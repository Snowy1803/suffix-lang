//
//  Instruction.swift
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

public enum Instruction: ASTEnum {
    case push(PushInstruction)
    case call(CallInstruction)
    case bind(BindInstruction)
    case function(FunctionInstruction)
    case record(RecordInstruction)
    case `enum`(EnumInstruction)
    
    public var node: ASTNode {
        switch self {
        case .push(let node as ASTNode),
             .call(let node as ASTNode),
             .bind(let node as ASTNode),
             .function(let node as ASTNode),
             .record(let node as ASTNode),
             .enum(let node as ASTNode):
            return node
        }
    }
}
