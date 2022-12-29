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
    func buildInstruction(context: FunctionParsingContext) -> PushStmt {
        let value = value.buildValue(context: context)
        let element = TStackElement(value: value)
        context.stack.append(element)
        return PushStmt(element: element, source: self)
    }
}
