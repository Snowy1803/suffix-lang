//
//  CallStmt.swift
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

public class CallStmt {
    public let input: [TStackElement]
    public let function: ReferenceVal
    /// the type of the function that will be called, after conversion from ``function.type``. should be concrete (no remaining generics or variadics).
    public let functionType: FunctionType
    public let source: CallInstruction
    
    init(input: [TStackElement], function: ReferenceVal, functionType: FunctionType, source: CallInstruction) {
        self.input = input
        self.function = function
        self.functionType = functionType
        self.source = source
    }
}
