//
//  TStackElement.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 27/12/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

public class TStackElement {
    public let value: Val
    
    init(value: Val) {
        self.value = value
    }
    
    public enum Source {
        case push(PushInstruction)
        case call(CallInstruction)
    }
}
