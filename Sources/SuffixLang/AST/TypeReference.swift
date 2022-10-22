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

enum TypeReference {
    case primitive(PrimitiveTypeReference)
//    case array(ArrayTypeReference)
    case function(FunctionTypeReference)
    
    var node: ASTNode {
        switch self {
        case .primitive(let node as ASTNode),
             .function(let node as ASTNode):
            return node
        }
    }
}

struct PrimitiveTypeReference: ASTNode {
    var literal: Token
    var type: PrimitiveType
    
    var nodeData: String { literal.data.debugDescription }
    var nodeChildren: [ASTElement] { [] }
}

struct FunctionTypeReference: ASTNode {
    var arguments: Arguments
    var returning: Arguments
    
    var nodeChildren: [ASTElement] {
        [
            ASTElement(name: "arguments", value: [arguments]),
            ASTElement(name: "returning", value: [returning]),
        ]
    }
    
    struct Arguments: ASTNode {
        var open: Token
        var arguments: [Argument]
        var close: Token
        
        var nodeChildren: [ASTElement] {
            [
                ASTElement(name: "arguments", value: arguments.map { $0 })
            ]
        }
    }
    
    struct Argument: ASTNode {
        var spec: Spec
        var typeAnnotation: TypeAnnotation?
        var trailingComma: Token
        
        var nodeChildren: [ASTElement] {
            [
                ASTElement(name: "spec", value: [spec.node]),
                ASTElement(name: "typeAnnotation", value: typeAnnotation),
            ]
        }
        
        enum Spec {
            case count(ConstantValue)
            case variadic(Variadic)
            case named(ConstantValue)
            
            var node: ASTNode {
                switch self {
                case .count(let node as ASTNode),
                     .variadic(let node as ASTNode),
                     .named(let node as ASTNode):
                    return node
                }
            }
        }
        
        struct Variadic: SingleTokenASTNode {
            var token: Token
        }
    }
}

struct TypeAnnotation: ASTNode {
    var colon: Token
    var type: TypeReference
    
    var nodeChildren: [ASTElement] {
        [ASTElement(name: "type", value: [type.node])]
    }
}
