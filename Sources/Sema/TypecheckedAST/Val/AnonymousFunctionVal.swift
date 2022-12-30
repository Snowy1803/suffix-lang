//
//  AnonymousFunctionVal.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 03/11/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

public class AnonymousFunctionVal: ASTNode {
    public let generics: [GenericArchetype]
    public var type: FunctionType
    public let source: AnonymousFunctionValue
    public var traits: TraitContainer
    public var content: [Stmt] = []
    
    init(generics: [GenericArchetype], type: FunctionType, source: AnonymousFunctionValue, traits: TraitContainer) {
        self.generics = generics
        self.type = type
        self.source = source
        self.traits = traits
    }
}

extension AnonymousFunctionVal: CustomStringConvertible {
    public var description: String {
        let traits = traits.traits.keys.map(\.wrapped.name).sorted().map { ", " + $0 }.joined()
        let firstline = "func \(type)\(traits) {"
        let statements = content.map(\.description)
            .joined(separator: "\n")
            .split(separator: "\n")
            .map { "    " + $0 }
            .joined(separator: "\n")
        return "\(firstline)\n\(statements)\n}"
    }
}
