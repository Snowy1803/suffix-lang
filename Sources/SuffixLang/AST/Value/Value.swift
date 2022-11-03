//
//  Value.swift
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

enum Value: ASTEnum {
    case int(IntegerValue)
    case float(FloatValue)
    case string(StringValue)
    case reference(ReferenceValue)
    case anonymousFunc(AnonymousFunctionValue)
    
    var node: ASTNode {
        switch self {
        case .int(let node as ASTNode),
             .float(let node as ASTNode),
             .string(let node as ASTNode),
             .reference(let node as ASTNode),
             .anonymousFunc(let node as ASTNode):
            return node
        }
    }
}
