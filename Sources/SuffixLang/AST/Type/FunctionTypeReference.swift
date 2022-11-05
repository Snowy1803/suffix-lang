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

public struct FunctionTypeReference: ASTNode {
    public var arguments: Arguments
    public var returning: ReturnValues
    
    public struct Arguments: ASTNode {
        public var open: Token
        public var arguments: [Argument]
        public var close: Token
    }
    
    public struct Argument: ASTNode {
        public var spec: Spec
        public var typeAnnotation: TypeAnnotation?
        public var trailingComma: Token?
        
        public enum Spec: ASTEnum {
            case count(IntegerValue)
            case unnamedVariadic(Variadic)
            case named(Named)
            
            public var node: ASTNode {
                switch self {
                case .count(let node as ASTNode),
                     .unnamedVariadic(let node as ASTNode),
                     .named(let node as ASTNode):
                    return node
                }
            }
            
            public struct Variadic: ASTNode {
                public var token: Token
            }
            
            public struct Named: ASTNode {
                public var name: Token
                public var variadic: Variadic?
            }
        }
    }
    
    public struct ReturnValues: ASTNode {
        public var open: Token
        public var arguments: [ReturnValue]
        public var close: Token
    }
    
    public struct ReturnValue: ASTNode {
        public var spec: Spec
        public var trailingComma: Token?
        
        public enum Spec: ASTEnum {
            case count(Count)
            case single(TypeReference)
            
            public var node: ASTNode {
                switch self {
                case .count(let node as ASTNode),
                     .single(let node as ASTNode):
                    return node
                }
            }
            
            public struct Count: ASTNode {
                public var count: IntegerValue
                public var typeAnnotation: TypeAnnotation?
            }
        }
    }
}
