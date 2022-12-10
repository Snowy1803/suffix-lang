//
//  TraitCollection.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 10/12/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public struct TraitCollection: ASTNode {
    public var traits: [Trait]
    
    public struct Trait: ASTNode {
        public var comma: Token
        public var trait: TraitReference
    }
}

public struct TraitReference: ASTNode {
    public var name: Identifier
    public var generics: GenericTypeArguments?
}
