//
//  TraitCollection+Parse.swift
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

extension TraitCollection {
    init(stream: TokenStream) {
        self.traits = []
        while let trait = Trait(stream: stream) {
            traits.append(trait)
        }
    }
}

extension TraitCollection.Trait {
    init?(stream: TokenStream) {
        guard let comma = stream.consumeOne(type: .comma) else {
            return nil
        }
        self.comma = comma
        self.trait = TraitReference(assert: stream)
    }
}

extension TraitReference {
    init?(stream: TokenStream) {
        guard let name = Identifier(stream: stream, allow: .inTraitName) else {
            return nil
        }
        self.name = name
        self.generics = GenericTypeArguments(stream: stream)
    }
    
    init(assert stream: TokenStream) {
        self.name = Identifier(assert: stream, allow: .inTraitName)
        self.generics = GenericTypeArguments(stream: stream)
    }
}
