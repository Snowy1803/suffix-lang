//
//  Function.swift
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

class Function {
    var parent: Function?
    var name: String
    var type: FunctionType
    var source: Source
    
    // these are empty if builtin or synthesized
    var arguments: [LocalRef]
    var instructions: [Inst]
    
    init(parent: Function?, name: String, type: FunctionType, source: Source) {
        self.parent = parent
        self.name = name
        self.type = type
        self.source = source
        self.arguments = [] // this is populated by the resolver
        self.instructions = []
    }
    
    enum Source {
        case instruction(FunctionInstruction)
        case anonymous(AnonymousFunctionValue)
        case main
        case builtin
        case synthesized
    }
}
