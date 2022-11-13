//
//  EnumType.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 05/11/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

public class EnumType: NamedType, LeafType {
    public var name: String
    public var cases: [Case]
    
    init(name: String, cases: [Case]) {
        self.name = name
        self.cases = cases
    }
    
    public struct Case {
        public var name: String
        public var source: BindInstruction? // nil if builtin
    }
}

extension EnumType {
    static let bool = EnumType(name: "bool", cases: [Case(name: "false"), Case(name: "true")])
}

extension EnumType {
    var caseBindings: [Binding] {
        cases.enumerated().map { i, c in
            Binding(name: c.name, type: self, source: c.source.map { Binding.Source.binding($0) } ?? .builtin, ref: .intLiteral(i))
        }
    }
}
