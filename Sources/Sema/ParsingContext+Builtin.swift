//
//  ParsingContext+Builtin.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 23/10/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

extension ParsingContext {
    static let builtin: ParsingContext = {
        let builtin = ParsingContext(parent: nil)
        let any = AnyType()
        let bool = EnumType.bool
        let str = StringType()
        builtin.types = [
            any,
            IntType(),
            FloatType(),
            bool,
            str,
        ]
        builtin.bindings = EnumType.bool.caseBindings + [
            Binding(name: "join", type: FunctionType(
                arguments: [.init(type: str, variadic: true)],
                returning: [.init(type: str)]), source: .builtin),
            Binding(name: "print", type: FunctionType(
                arguments: [.init(type: any, variadic: true)],
                returning: []), source: .builtin),
        ]
        return builtin
    }()
}
