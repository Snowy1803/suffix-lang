//
//  ParsingContext.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 23/10/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

class ParsingContext {
    var parent: ParsingContext?
    var types: [NamedType] = []
    var traits: [Trait] = []
    private(set) var bindings: [TBinding] = []
    
    init(parent: ParsingContext?) {
        self.parent = parent
    }
    
    func getBindings(name: String) -> [TBinding] {
        var result = parent?.getBindings(name: name) ?? []
        result.append(contentsOf: bindings.filter({ $0.name == name }))
        return result
    }
    
    func add(global: Bool, binding: TBinding) {
        self.bindings.append(binding)
    }
    
    func getType(name: String) -> NamedType? {
        if let type = types.first(where: { $0.name == name }) {
            return type
        }
        return parent?.getType(name: name)
    }
    
    func getTrait(name: String) -> Trait? {
        if let trait = traits.first(where: { $0.wrapped.name == name }) {
            return trait
        }
        return parent?.getTrait(name: name)
    }
    
    var typeChecker: TypeChecker! {
        parent?.typeChecker
    }
}
