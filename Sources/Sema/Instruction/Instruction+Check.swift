//
//  Instruction+Check.swift
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

extension Instruction {
    func typeCheck(context: FunctionParsingContext) {
        switch self {
        case .push(_):
            // TODO: implement
            break
        case .call(_):
            // TODO: implement
            break
        case .bind(_):
            // TODO: implement
            break
        case .function(let function):
            let subcontext = function.createSubContext(parent: context)
            function.block.content.instructions.forEach { inst in
                inst.typeCheck(context: subcontext)
            }
        case .record(let record):
            record.resolve(context: context)
        }
    }
}

extension RecordInstruction {
    func resolve(context: FunctionParsingContext) {
        let record = RecordType(name: name.identifier, fields: [])
        record.fields = block.content.map { (bind: BindInstruction) -> RecordType.Field in
            let inner: SType
            if let annotation = bind.value.typeAnnotation {
                inner = annotation.type.resolve(context: context)
            } else {
                context.typeChecker.diagnostics.append(Diagnostic(token: bind.value.literal, message: .missingTypeAnnotation, severity: .warning))
                inner = AnyType.shared
            }
            context.bindings.append(Binding(
                name: bind.value.literal.identifier,
                type: FunctionType(arguments: [.init(type: record)], returning: [.init(type: inner)]),
                source: .recordFieldAccessor(record, self, bind)))
            return RecordType.Field(name: bind.value.literal.identifier, type: inner, source: bind)
        }
        context.bindings.append(Binding(
            name: "new \(name.identifier)",
            type: FunctionType(arguments: record.fields.map { .init(type: $0.type) }, returning: [.init(type: record)]),
            source: .recordConstructor(record, self)))
        context.types.append(record)
    }
}
