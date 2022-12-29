//
//  EnumInstruction+Check.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 10/12/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

extension EnumInstruction {
    func registerTypeDeclaration(context: FunctionParsingContext) -> EnumType {
        let type = EnumType(name: name.identifier, cases: [], source: .instruction(self))
        context.types.append(type)
        return type
    }
}

extension EnumType {
    func registerGlobalBindings(context: FunctionParsingContext) {
        let source = source.asInstruction!
        self.cases = source.block.content.enumerated().map { (index: Int, bind: BindInstruction) -> Case in
            if let annotation = bind.value.typeAnnotation {
                context.typeChecker.diagnostics.append(Diagnostic(tokens: annotation.nodeAllTokens, message: .invalidTypeAnnotation, severity: .error))
            }
            let name = bind.value.literal.identifier
            context.add(global: true, binding: TBinding(
                name: name,
                type: self,
                source: .enumCase(self, source, bind),
                content: .builtin(.int(IntVal(value: index, type: self, source: .builtin)))))
            return Case(name: bind.value.literal.identifier, source: bind)
        }
        // TODO: add synthesized `eq` and `hash` implementation
//        context.typeChecker.logger.log(.enumCreated(type))
    }
}
