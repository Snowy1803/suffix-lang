//
//  BuiltinParsingContext.swift
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

class BuiltinParsingContext: ParsingContext {
    static let shared: BuiltinParsingContext = BuiltinParsingContext()
    
    private init() {
        let any = AnyType.shared
        let bool = EnumType.bool
        let str = StringType.shared
        super.init(parent: nil)
        self.types = [
            any,
            IntType.shared,
            FloatType.shared,
            bool,
            str,
        ]
        self.bindings = EnumType.bool.caseBindings + [
            Binding(name: "join", type: FunctionType(
                arguments: [.init(type: str, variadic: true)],
                returning: [.init(type: str)]), source: .builtin),
            Binding(name: "print", type: FunctionType(
                arguments: [.init(type: any, variadic: true)],
                returning: []), source: .builtin),
            GenericArchetype(name: "T")
                .with { t in
                    Binding(name: "select", type: FunctionType(
                        generics: [t],
                        arguments: [.init(type: bool), .init(type: t), .init(type: t)],
                        returning: [.init(type: t)]), source: .builtin)
                },
        ]
    }
}
