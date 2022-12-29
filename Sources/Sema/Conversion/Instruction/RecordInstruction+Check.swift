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
    func registerTypeDeclaration(context: FunctionParsingContext) -> RecordType {
        let record = RecordType(name: name.identifier, fields: [], source: .instruction(self))
        context.types.append(record)
        return record
    }
}

extension RecordType {
    func registerGlobalBindings(context: FunctionParsingContext) {
        let source = source.asInstruction!
        self.fields = source.block.content.map { (bind: BindInstruction) -> RecordType.Field in
            let inner: SType
            if let annotation = bind.value.typeAnnotation {
                inner = annotation.type.resolve(context: context)
            } else {
                context.typeChecker.diagnostics.append(Diagnostic(tokens: bind.value.literal.tokens, message: .missingTypeAnnotation, severity: .warning))
                inner = AnyType.shared
            }
            let name = bind.value.literal.identifier
            let type = FunctionType(arguments: [.init(type: self)], returning: [.init(type: inner)], traits: TraitContainer(type: .func, source: false, traits: [], diagnostics: &context.typeChecker.diagnostics))
            context.add(global: true, binding: TBinding(
                name: name,
                type: type,
                source: .recordFieldAccessor(self, source, bind),
                content: .builtinFunction))
            return RecordType.Field(name: bind.value.literal.identifier, type: inner, source: bind)
        }
        let constructorName = "new \(name)"
        let constructorType = FunctionType(arguments: self.fields.map { .init(type: $0.type) }, returning: [.init(type: self)], traits: TraitContainer(type: .func, source: false, traits: [], diagnostics: &context.typeChecker.diagnostics))
        context.add(global: true, binding: TBinding(
            name: constructorName,
            type: constructorType,
            source: .recordConstructor(self, source),
            content: .builtinFunction))
//        context.typeChecker.logger.log(.recordCreated(record))
    }
}
