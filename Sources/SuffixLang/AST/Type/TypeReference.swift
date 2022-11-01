//
//  TypeReference.swift
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

enum TypeReference: ASTEnum {
    case generic(GenericTypeReference)
    case function(FunctionTypeReference)
    
    var node: ASTNode {
        switch self {
        case .generic(let node as ASTNode),
             .function(let node as ASTNode):
            return node
        }
    }
}

struct TypeAnnotation: ASTNode {
    var colon: Token
    var type: TypeReference
}
