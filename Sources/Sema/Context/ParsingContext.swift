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
    var bindings: [Binding] = []
    
    init(parent: ParsingContext?) {
        self.parent = parent
    }
    
    func getBindings(name: String) -> [Binding] {
        var result = parent?.getBindings(name: name) ?? []
        result.append(contentsOf: bindings.filter({ $0.name == name }))
        return result
    }
    
    func capture(binding: Binding, node: ASTNode) -> Ref! {
        // see FunctionParsingContext.capture(binding:node:)
        if bindings.contains(where: { $0 === binding }) {
            return binding.ref
        }
        return parent?.capture(binding: binding, node: node)
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
