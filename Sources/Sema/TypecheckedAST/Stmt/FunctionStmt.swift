//
//  FunctionStmt.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 22/10/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

public class FunctionStmt {
    public let name: String
    public let generics: [GenericArchetype]
    public var type: FunctionType
    public var traits: TraitContainer
    public let source: FunctionInstruction
    public var content: [Stmt] = []

    init(name: String, generics: [GenericArchetype], type: FunctionType, traits: TraitContainer, source: FunctionInstruction) {
        self.name = name
        self.generics = generics
        self.type = type
        self.traits = traits
        self.source = source
    }
}

extension FunctionStmt: CustomStringConvertible {
    public var description: String {
        let traits = traits.traits.keys.map(\.wrapped.name).sorted().map { ", " + $0 }.joined()
        let firstline = "func \(name) \(type)\(traits) {"
        let statements = content.map(\.description)
            .joined(separator: "\n")
            .split(separator: "\n")
            .map { "    " + $0 }
            .joined(separator: "\n")
        return "\(firstline)\n\(statements)\n}"
    }
}
