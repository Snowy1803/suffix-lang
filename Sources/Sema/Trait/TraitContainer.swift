//
//  TraitContainer.swift
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

struct TraitContainer {
    var type: TraitContainerType
    var traits: [TraitInfo]
    
    struct TraitInfo {
        var trait: Trait
        var source: Source
        
        enum Source {
            case builtin
        }
    }
}

extension TraitContainer {
    init(type: TraitContainerType, builtin: [Trait]) {
        self.type = type
        self.traits = builtin.map { TraitInfo(trait: $0, source: .builtin) }
    }
    
    var accessControl: AccessControlTrait {
        for trait in traits {
            if case .accessControl(let result) = trait.trait {
                return result
            }
        }
        // default
        switch type {
        case .trait, .record, .enum, .func:
            return .internal
        }
    }
}
