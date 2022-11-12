//
//  StackElement.swift
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

class StackElement {
    var type: SType // if we want backwards inference, we may not be sure about the type until later
    let source: Source
    
    init(type: SType, source: Source) {
        self.type = type
        self.source = source
    }
    
    enum Source {
        /// This value was pushed explicitly
        case push(PushInstruction)
        /// This value was returned by a function call
        case returnValue(CallInstruction)
        /// This value is an unnamed argument
        case argument(FunctionTypeReference.Argument)
    }
}
