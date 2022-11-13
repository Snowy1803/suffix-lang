//
//  RecordInstruction+Check.swift
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

extension RecordInstruction {
    func resolve(context: FunctionParsingContext) {
        let record = RecordType(name: name.identifier, fields: [])
        record.fields = block.content.map { (bind: BindInstruction) -> RecordType.Field in
            let inner: SType
            if let annotation = bind.value.typeAnnotation {
                inner = annotation.type.resolve(context: context)
            } else {
                context.typeChecker.diagnostics.append(Diagnostic(tokens: bind.value.literal.tokens, message: .missingTypeAnnotation, severity: .warning))
                inner = AnyType.shared
            }
            let name = bind.value.literal.identifier
            let type = FunctionType(arguments: [.init(type: record)], returning: [.init(type: inner)])
            context.bindings.append(Binding(
                name: name,
                type: type,
                source: .recordFieldAccessor(record, self, bind),
                ref: .function(context.createFunction(name: name, type: type, source: .synthesized))))
            return RecordType.Field(name: bind.value.literal.identifier, type: inner, source: bind)
        }
        let constructorName = "new \(name.identifier)"
        let constructorType = FunctionType(arguments: record.fields.map { .init(type: $0.type) }, returning: [.init(type: record)])
        context.bindings.append(Binding(
            name: constructorName,
            type: constructorType,
            source: .recordConstructor(record, self),
            ref: .function(context.createFunction(name: constructorName, type: constructorType, source: .synthesized))))
        context.types.append(record)
    }
}
