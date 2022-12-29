//
//  PushInstruction+Build.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 19/11/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

extension PushInstruction {
    func buildInstruction(context: FunctionParsingContext) {
        let (ref, type) = value.buildValue(context: context)
        context.stack.append(StackElement(type: type, source: .push(self), ref: ref.value))
    }
}
