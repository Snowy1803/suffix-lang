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
    public var source: Source
    
    init(name: String, cases: [Case], source: Source) {
        self.name = name
        self.cases = cases
        self.source = source
    }
    
    public struct Case {
        public var name: String
        public var source: BindInstruction? // nil if builtin
    }
    
    public enum Source {
        case instruction(EnumInstruction)
        case builtin
        
        var asInstruction: EnumInstruction? {
            switch self {
            case .instruction(let enumInstruction):
                return enumInstruction
            case .builtin:
                return nil
            }
        }
    }
}

extension EnumType {
    static let bool = EnumType(name: "bool", cases: [Case(name: "false"), Case(name: "true")], source: .builtin)
}

extension EnumType {
    public var declarationDescription: String {
        let firstline = "enum \(name) {"
        let cases = self.cases.map(\.name).map { "    > \($0)\n" }.joined()
        return "\(firstline)\n\(cases)}"
    }
}
//
//extension EnumType {
//    var caseBindings: [TBinding] {
//        cases.enumerated().map { i, c in
//            TBinding(name: c.name, type: self, source: c.source.map { TBinding.Source.binding($0) } ?? .builtin, ref: .intLiteral(i))
//        }
//    }
//}
