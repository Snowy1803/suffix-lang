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
    /// The type of the value
    let type: SType // if we want backwards inference, we may not be sure about the type until later
    /// The source mapping for this binding, for diagnostics
    let source: Source
    /// The underlying value
    let ref: Ref
    
    init(type: SType, source: Source, ref: Ref) {
        self.type = type
        self.source = source
        self.ref = ref
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
