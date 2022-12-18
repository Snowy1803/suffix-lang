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
    func registerTypeDeclaration(context: FunctionParsingContext) {
        let record = RecordType(name: name.identifier, fields: [], source: .instruction(self))
        context.types.append(record)
    }
    
    func registerGlobalBindings(context: FunctionParsingContext) {
        guard let record = context.types.compactMap({ $0 as? RecordType }).first(where: { (type: RecordType) in
            if case .instruction(let inst) = type.source {
                return inst === self
            }
            return false
        }) else {
            assertionFailure()
            return
        }
        record.fields = block.content.map { (bind: BindInstruction) -> RecordType.Field in
            let inner: SType
            if let annotation = bind.value.typeAnnotation {
                inner = annotation.type.resolve(context: context)
            } else {
                context.typeChecker.diagnostics.append(Diagnostic(tokens: bind.value.literal.tokens, message: .missingTypeAnnotation, severity: .warning))
                inner = AnyType.shared
            }
            let name = bind.value.literal.identifier
            let type = FunctionType(arguments: [.init(type: record)], returning: [.init(type: inner)], traits: TraitContainer(type: .func, source: false, traits: [], diagnostics: &context.typeChecker.diagnostics))
            context.add(global: true, binding: Binding(
                name: name,
                type: type,
                source: .recordFieldAccessor(record, self, bind),
                ref: .function(context.createFunction(name: name, type: type, source: .synthesized, traits: TraitContainer(type: .func, source: true, traits: [], diagnostics: &context.typeChecker.diagnostics)))))
            return RecordType.Field(name: bind.value.literal.identifier, type: inner, source: bind)
        }
        let constructorName = "new \(name.identifier)"
        let constructorType = FunctionType(arguments: record.fields.map { .init(type: $0.type) }, returning: [.init(type: record)], traits: TraitContainer(type: .func, source: false, traits: [], diagnostics: &context.typeChecker.diagnostics))
        context.add(global: true, binding: Binding(
            name: constructorName,
            type: constructorType,
            source: .recordConstructor(record, self),
            ref: .function(context.createFunction(name: constructorName, type: constructorType, source: .synthesized, traits: TraitContainer(type: .func, source: true, traits: [], diagnostics: &context.typeChecker.diagnostics)))))
    }
}
