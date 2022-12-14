//
//  Trait.swift
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

enum Trait: Equatable, Hashable {
    case accessControl(AccessControlTrait)
    case function(FunctionTrait)
    case callingConvention(CallingConventionTrait)
    case trait(TraitTrait)
    
    var wrapped: TraitProtocol {
        switch self {
        case .accessControl(let trait as TraitProtocol),
             .function(let trait as TraitProtocol),
             .callingConvention(let trait as TraitProtocol),
             .trait(let trait as TraitProtocol):
            return trait
        }
    }
}

protocol TraitProtocol {
    var name: String { get }
    var traits: TraitContainer { get }
    var exclusiveWith: Set<Trait> { get }
    var implies: Set<Trait> { get }
}

extension TraitProtocol where Self: RawRepresentable, Self.RawValue == String {
    var name: String { rawValue }
}

extension Trait {
    static let allBuiltins: [Trait] = {
        var allBuiltins: [Trait] = []
        allBuiltins.append(contentsOf: AccessControlTrait.allCases.map({ .accessControl($0) }))
        allBuiltins.append(contentsOf: FunctionTrait.allCases.map({ .function($0) }))
        allBuiltins.append(contentsOf: CallingConventionTrait.allCases.map({ .callingConvention($0) }))
        allBuiltins.append(contentsOf: TraitTrait.allCases.map({ .trait($0) }))
        return allBuiltins
    }()
}
