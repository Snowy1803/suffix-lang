//
//  FunctionTypeReference.swift
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

struct FunctionTypeReference: ASTNode {
    var arguments: Arguments
    var returning: ReturnValues
    
    struct Arguments: ASTNode {
        var open: Token
        var arguments: [Argument]
        var close: Token
    }
    
    struct Argument: ASTNode {
        var spec: Spec
        var typeAnnotation: TypeAnnotation?
        var trailingComma: Token?
        
        enum Spec: ASTEnum {
            case count(IntegerValue)
            case unnamedVariadic(Variadic)
            case named(Named)
            
            var node: ASTNode {
                switch self {
                case .count(let node as ASTNode),
                     .unnamedVariadic(let node as ASTNode),
                     .named(let node as ASTNode):
                    return node
                }
            }
            
            struct Variadic: ASTNode {
                var token: Token
            }
            
            struct Named: ASTNode {
                var name: Token
                var variadic: Variadic?
            }
        }
    }
    
    struct ReturnValues: ASTNode {
        var open: Token
        var arguments: [ReturnValue]
        var close: Token
    }
    
    struct ReturnValue: ASTNode {
        var spec: Spec
        var trailingComma: Token?
        
        enum Spec: ASTEnum {
            case count(Count)
            case single(TypeReference)
            
            var node: ASTNode {
                switch self {
                case .count(let node as ASTNode),
                     .single(let node as ASTNode):
                    return node
                }
            }
            
            struct Count: ASTNode {
                var count: IntegerValue
                var typeAnnotation: TypeAnnotation?
            }
        }
    }
}
