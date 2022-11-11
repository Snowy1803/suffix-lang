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

public class RecordType: NamedType, LeafType { // TODO: when generic records arrive, it won't be a leaf anymore
    public var name: String
    public var fields: [Field]
    
    init(name: String, fields: [Field]) {
        self.name = name
        self.fields = fields
    }
    
    public struct Field {
        public var name: String
        public var type: SType
        public var source: BindInstruction? // nil if builtin
    }
}
