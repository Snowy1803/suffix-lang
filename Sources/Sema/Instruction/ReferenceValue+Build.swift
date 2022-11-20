//
//  ReferenceValue+Build.swift
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

extension ReferenceValue {
    func buildValue(context: FunctionParsingContext) -> (Ref, SType) {
        var bindings = context.getBindings(name: identifier.literal.identifier)
        let type = identifier.typeAnnotation?.type.resolve(context: context)
        if let type {
            bindings = bindings.filter({ $0.type.canBeAssigned(to: type) })
        }
        // TODO: resolve generics and count
        // canBeAssigned has to go
        guard let binding = bindings.last else {
            context.typeChecker.diagnostics.append(Diagnostic(tokens: identifier.literal.tokens, message: .noViableBinding(identifier.literal.identifier), severity: .error))
            return (.intLiteral(0), type ?? AnyType.shared) // this may make additional unwanted errors
        }
        return (context.builder.buildCopy(value: binding.ref, type: binding.type), binding.type)
    }
}
