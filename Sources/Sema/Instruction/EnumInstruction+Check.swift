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
    func registerTypeDeclaration(context: FunctionParsingContext) {
        let type = EnumType(name: name.identifier, cases: [], source: .instruction(self))
        context.types.append(type)
    }
    
    func registerGlobalBindings(context: FunctionParsingContext) {
        guard let type = context.types.compactMap({ $0 as? EnumType }).first(where: { (type: EnumType) in
            if case .instruction(let inst) = type.source {
                return inst === self
            }
            return false
        }) else {
            assertionFailure()
            return
        }
        type.cases = block.content.enumerated().map { (index: Int, bind: BindInstruction) -> EnumType.Case in
            if let annotation = bind.value.typeAnnotation {
                context.typeChecker.diagnostics.append(Diagnostic(tokens: annotation.nodeAllTokens, message: .invalidTypeAnnotation, severity: .error))
            }
            let name = bind.value.literal.identifier
            context.bindings.append(Binding(
                name: name,
                type: type,
                source: .enumCase(type, self, bind),
                ref: .intLiteral(index)))
            return EnumType.Case(name: bind.value.literal.identifier, source: bind)
        }
        // TODO: add synthesized `eq` and `hash` implementation
    }
}
