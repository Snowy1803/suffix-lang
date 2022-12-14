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
        self.traits = Trait.allBuiltins
        self.types = [
            any,
            IntType.shared,
            FloatType.shared,
            bool,
            str,
            GenericArchetype(name: "Element").with {
                ArrayType(element: $0)
            },
        ]
        self.bindings = EnumType.bool.caseBindings
        createBuiltinFunction(
            name: "join", type: FunctionType(
                arguments: [.init(type: str, variadic: true)],
                returning: [.init(type: str)]),
            traits: TraitContainer(type: .func, builtin: [.function(.constant)]))
        createBuiltinFunction(
            name: "print", type: FunctionType(
                arguments: [.init(type: any, variadic: true)],
                returning: []),
            traits: TraitContainer(type: .func, builtin: [.function(.impure)]))
        createBuiltinFunction(
            name: "select", type: GenericArchetype(name: "T")
                .with { t in
                    FunctionType(
                        generics: [t],
                        arguments: [.init(type: bool), .init(type: t), .init(type: t)],
                        returning: [.init(type: t)])
                },
            traits: TraitContainer(type: .func, builtin: [.function(.constant)]))
    }
    
    func createBuiltinFunction(name: String, type: FunctionType, traits: TraitContainer) {
        let function = Function(parent: nil, name: name, type: type, source: .builtin, traits: traits)
        self.bindings.append(Binding(name: name, type: type, source: .builtin, ref: .function(function)))
    }
}
