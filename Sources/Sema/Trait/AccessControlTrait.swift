//
//  AccessControlTrait.swift
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

enum AccessControlTrait: String, TraitProtocol, Equatable, Hashable, CaseIterable {
    
    case `private`
    case `internal`
    case hidden
    case `public`
    case open
    
    var exclusiveWith: Set<Trait> {
        Set(Set(Self.allCases).subtracting([self]).map { Trait.accessControl($0) })
    }
    
    var implies: Set<Trait> {
        if self == .hidden || self == .public {
            return [.function(.noCapture)]
        }
        return []
    }
    
    var traits: TraitContainer {
        if self == .open {
            return TraitContainer(type: .trait, builtin: [.trait(.sourceTrait), .trait(.traitTrait)])
        } else {
            return TraitContainer(type: .trait, builtin: [.trait(.sourceTrait), .trait(.traitTrait), .trait(.typeTrait), .trait(.funcTrait)])
        }
    }
}
