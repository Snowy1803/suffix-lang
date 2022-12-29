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
        for binding in EnumType.bool.caseBindings {
            self.add(global: true, binding: binding)
        }
        createBuiltinFunction(
            name: "join",
            arguments: [.init(type: str, variadic: true)],
            returning: [str],
            traits: [.function(.constant)])
        createBuiltinFunction(
            name: "print",
            arguments: [.init(type: any, variadic: true)],
            returning: [],
            traits: [.function(.impure)])
        GenericArchetype(name: "T")
            .with { t in
                createBuiltinFunction(
                    name: "select",
                    generics: [t],
                    arguments: [.init(type: bool), .init(type: t), .init(type: t)],
                    returning: [t],
                    traits: [.function(.constant)])
            }
    }
    
    func createBuiltinFunction(name: String, generics: [GenericArchetype] = [], arguments: [FunctionType.Argument], returning: [SType], traits: [Trait]) {
        let type = FunctionType(
            generics: generics,
            arguments: arguments,
            returning: returning.map { .init(type: $0) },
            traits: TraitContainer(type: .func, source: false, builtin: traits))
        let function = Function(
            parent: nil,
            name: name,
            type: type,
            source: .builtin,
            traits: TraitContainer(type: .func, source: true, builtin: traits))
        self.add(global: true, binding: Binding(name: name, type: type, source: .builtin, ref: .function(function)))
    }
}
