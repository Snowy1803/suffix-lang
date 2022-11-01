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
    case constant(ConstantValue)
    case string(StringValue)
    case reference(ReferenceValue)
    case anonymousFunc(AnonymousFunctionValue)
    
    var node: ASTNode {
        switch self {
        case .constant(let node as ASTNode),
             .string(let node as ASTNode),
             .reference(let node as ASTNode),
             .anonymousFunc(let node as ASTNode):
            return node
        }
    }
}

struct ConstantValue: ASTNode {
    var token: Token
    
    var integer: Int {
        if case .int(let int) = token.data {
            return int
        }
        return 0
    }
}

struct StringValue: ASTNode {
    var token: Token
}

struct ReferenceValue: ASTNode {
    var literal: Token
    var typeAnnotation: TypeAnnotation?
    
    var identifier: String {
        if case .identifier(let id) = literal.data {
            return id
        }
        // happens in the case of a synthesized missing token
        return literal.literal.description
    }
}

struct AnonymousFunctionValue: ASTNode {
    var keyword: Token
    var arguments: FunctionTypeReference.Arguments
    var returning: FunctionTypeReference.Arguments
    var block: Block
}
