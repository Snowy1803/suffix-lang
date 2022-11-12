//
//  Binding.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 06/11/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

class Binding {
    let name: String
    let type: SType
    let source: Source
    
    init(name: String, type: SType, source: Source) {
        self.name = name
        self.type = type
        self.source = source
    }
    
    enum Source {
        /// This value is an explicit binding
        case binding(BindInstruction)
        /// This value is a named argument
        case argument(FunctionTypeReference.Argument)
        /// This value is a function
        case function(FunctionInstruction)
        /// This value is built in the language
        case builtin
        /// This value is the accessor function for a defined record's field
        case recordFieldAccessor(RecordType, RecordInstruction, BindInstruction)
        /// This value is the constructor function for a defined record
        case recordConstructor(RecordType, RecordInstruction)
    }
}
