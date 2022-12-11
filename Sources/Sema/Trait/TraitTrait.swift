//
//  TraitTrait.swift
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

enum TraitTrait: String, TraitProtocol, Equatable, Hashable, CaseIterable {
    
    case sourceTrait = "source trait"
    case funcTrait = "func trait"
    case typeTrait = "type trait"
    case recordTrait = "record trait"
    case enumTrait = "enum trait"
    case traitTrait = "trait trait"
    
    var exclusiveWith: Set<Trait> {
        []
    }
    
    var implies: Set<Trait> {
        switch self {
        case .typeTrait:
            return [.trait(.recordTrait), .trait(.enumTrait)]
        case .sourceTrait, .funcTrait, .recordTrait, .enumTrait, .traitTrait:
            return []
        }
    }
    
    var traits: TraitContainer {
        TraitContainer(type: .trait, builtin: [.trait(.traitTrait)])
    }
}
