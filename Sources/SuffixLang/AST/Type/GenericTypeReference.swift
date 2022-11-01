//
//  GenericTypeReference.swift
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

struct GenericTypeReference: ASTNode {
    var name: Token
    var generics: GenericTypeArguments?
    
    var nodeChildren: [ASTElement] {
        []
    }
}

struct GenericTypeArguments: ASTNode {
    var open: Token
    var generics: [Generic]
    var close: Token
    
    var nodeChildren: [ASTElement] {
        [ASTElement(name: "generics", value: generics)]
    }
    
    struct Generic: ASTNode {
        var type: TypeReference
        var trailingComma: Token?
        
        var nodeChildren: [ASTElement] {
            [ASTElement(name: "type", value: type.node)]
        }
    }
}
