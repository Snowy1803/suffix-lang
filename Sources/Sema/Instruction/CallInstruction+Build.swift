//
//  CallInstruction+Build.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 19/11/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

extension CallInstruction {
    func buildInstruction(context: FunctionParsingContext) {
        let preErrorCount = context.typeChecker.diagnostics.lazy.filter({ $0.severity >= .error }).count
        let (value, type) = value.buildValue(context: context)
        guard let type = type as? FunctionType else {
            let postErrorCount = context.typeChecker.diagnostics.lazy.filter({ $0.severity >= .error }).count
            if postErrorCount == preErrorCount {
                context.typeChecker.diagnostics.append(Diagnostic(tokens: nodeAllTokens, message: .callNonCallable(self.value.identifier.literal.identifier, type), severity: .error))
            } // else there is already a diagnostic there
            return
        }
//        assert(type.isConcrete) // TODO: make it non-variadic in ReferenceValue.buildValue
        let count = type.arguments.count
        let parameters = context.pop(count: count, source: nodeAllTokens)
        // TODO: typecheck arguments (and resolve generics / specialise and stuff)
        let inst = context.builder.buildCallReturnInst(value: value, type: type, parameters: parameters.map({ param in
            LocatedRef(value: param.ref, stackElement: param)
        }))
        let result = inst.returning
        for ((i, ref), type) in zip(zip(result.indices, result), type.returning) {
            let elem = StackElement(type: type.type, source: .returnValue(self), ref: .local(ref.value))
            context.stack.append(elem)
            inst.returning[i].stackElement = elem
        }
    }
}
