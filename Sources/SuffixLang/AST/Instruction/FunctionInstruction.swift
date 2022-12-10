//
//  FunctionInstruction.swift
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

public class FunctionInstruction: ASTNode {
    public let keyword: Token
    public let name: Identifier
    public let generics: GenericDefinition?
    public let arguments: FunctionTypeReference.Arguments
    public let returning: FunctionTypeReference.ReturnValues
    public let traits: TraitCollection
    public let block: Block
    
    init(keyword: Token, name: Identifier, generics: GenericDefinition?, arguments: FunctionTypeReference.Arguments, returning: FunctionTypeReference.ReturnValues, traits: TraitCollection, block: Block) {
        self.keyword = keyword
        self.name = name
        self.generics = generics
        self.arguments = arguments
        self.returning = returning
        self.traits = traits
        self.block = block
    }
}
