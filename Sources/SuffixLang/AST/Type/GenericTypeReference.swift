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

public struct GenericTypeReference: ASTNode {
    public var name: Identifier
    public var generics: GenericTypeArguments?
}

public struct GenericTypeArguments: ASTNode {
    public var open: Token
    public var generics: [Generic]
    public var close: Token
    
    public struct Generic: ASTNode {
        public var type: TypeReference
        public var trailingComma: Token?
    }
}

public struct GenericDefinition: ASTNode {
    public var open: Token
    public var generics: [Generic]
    public var close: Token
    
    public struct Generic: ASTNode {
        public var name: Identifier
        public var trailingComma: Token?
    }
}

public struct GenericTraitsArgument: ASTNode {
    public var open: Token
    public var traits: [Generic]
    public var close: Token
    
    public struct Generic: ASTNode {
        public var trait: TraitReference
        public var trailingComma: Token?
    }
}
