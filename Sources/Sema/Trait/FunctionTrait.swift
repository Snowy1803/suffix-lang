//
//  FunctionTrait.swift
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

enum FunctionTrait: TraitProtocol, Equatable, Hashable, CaseIterable {
    
    case pure
    case impure
    case constant
    case extern
    
    var exclusiveWith: Set<Trait> {
        switch self {
        case .pure:
            return [.function(.impure)]
        case .impure:
            return [.function(.pure)]
        case .constant, .extern:
            return []
        }
    }
    
    var implies: Set<Trait> {
        return []
    }
    
    var traits: TraitContainer {
        if self == .extern {
            return TraitContainer(type: .trait, builtin: [.trait(.sourceTrait), .trait(.funcTrait)])
        } else {
            return TraitContainer(type: .trait, builtin: [.trait(.funcTrait)])
        }
    }
}
