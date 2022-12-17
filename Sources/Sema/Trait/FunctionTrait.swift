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

enum FunctionTrait: String, TraitProtocol, Equatable, Hashable, CaseIterable {
    
    case pure
    case impure
    case noCapture = "no capture"
    case constant
    case extern
    
    var exclusiveWith: Set<Trait> {
        switch self {
        case .pure:
            return [.function(.impure)]
        case .impure:
            return [.function(.pure)]
        case .noCapture:
            return []
        case .constant:
            return [.function(.extern)]
        case .extern:
            return [.function(.constant)]
        }
    }
    
    var implies: Set<Trait> {
        switch self {
        case .constant:
            return [.function(.pure), .function(.noCapture)]
        case .pure, .impure, .noCapture, .extern:
            return []
        }
    }
    
    var traits: TraitContainer {
        if self == .extern {
            return TraitContainer(builtinTraitWithTraits: [.trait(.sourceTrait), .trait(.funcTrait)])
        } else {
            return TraitContainer(builtinTraitWithTraits: [.trait(.funcTrait)])
        }
    }
}
