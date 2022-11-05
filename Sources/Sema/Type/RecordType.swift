//
//  RecordType.swift
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

public class RecordType: NamedType {
    public var name: String
    public var fields: [Field]
    
    init(name: String, fields: [Field]) {
        self.name = name
        self.fields = fields
    }
    
    public func convertible(to other: SType) -> Bool {
        false
    }
    
    public struct Field {
        public var name: String
        public var type: SType
        public var source: BindInstruction? // nil if builtin
    }
}

extension RecordType {
    var fieldBindings: [ParsingContext.Binding] {
        fields.map {
            ParsingContext.Binding(name: $0.name, type: $0.type, source: $0.source.map { ParsingContext.Binding.Source.binding($0) } ?? .builtin)
        }
    }
}
