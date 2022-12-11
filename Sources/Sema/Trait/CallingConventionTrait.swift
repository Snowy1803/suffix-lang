//
//  CallingConventionTrait.swift
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

enum CallingConventionTrait: String, TraitProtocol, Equatable, Hashable, CaseIterable {
    
    case c
    case grph
    case suffix
    
    var exclusiveWith: Set<Trait> {
        Set(Set(Self.allCases).subtracting([self]).map { Trait.callingConvention($0) })
    }
    
    var implies: Set<Trait> {
        switch self {
        case .c, .grph:
            return [.function(.constant)]
        case .suffix:
            return []
        }
    }
    
    var traits: TraitContainer {
        TraitContainer(type: .trait, builtin: [.trait(.funcTrait)])
    }
}
