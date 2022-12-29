//
//  Value+Build.swift
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

extension Value {
    func buildValue(context: FunctionParsingContext) -> Val {
        switch self {
        case .int(let integer):
            return .int(IntVal(value: integer.integer, type: IntType.shared, source: .ast(integer)))
        case .float(let float):
            return .float(float)
        case .string(let str):
            // TODO: move interpolation here probably
            return .string(str)
        case .reference(let ref):
            return .reference(ref.buildValue(context: context))
        case .anonymousFunc(let fn):
            return fn.buildValue(context: context)
        }
    }
}
