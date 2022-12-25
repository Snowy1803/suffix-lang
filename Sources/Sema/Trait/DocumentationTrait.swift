//
//  DocumentationTrait.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 11/12/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

enum DocumentationTrait: String, TraitProtocol, Equatable, Hashable, CaseIterable {
    
    case deprecated = "deprecated"
    case beta = "beta"
    
    var exclusiveWith: Set<Trait> {
        []
    }
    
    var implies: Set<Trait> {
        []
    }
    
    var traits: TraitContainer {
        TraitContainer(builtinTraitWithTraits: [.trait(.sourceTrait), .trait(.traitTrait), .trait(.typeTrait), .trait(.funcTrait)])
    }
}
