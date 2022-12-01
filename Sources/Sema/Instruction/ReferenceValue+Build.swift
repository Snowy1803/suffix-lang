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
    func buildValue(context: FunctionParsingContext) -> (LocatedRef, SType) {
        var bindings = context.getBindings(name: identifier.literal.identifier)
        let type = identifier.typeAnnotation?.type.resolve(context: context)
        if let type {
            bindings = bindings.filter({ $0.type.canBeAssigned(to: type) })
        }
        // TODO: resolve generics and count
        // canBeAssigned has to go
        guard let binding = bindings.last else {
            context.typeChecker.diagnostics.append(Diagnostic(tokens: identifier.literal.tokens, message: .noViableBinding(identifier.literal.identifier), severity: .error))
            return (Ref.intLiteral(0).noLocation, type ?? AnyType.shared) // this may make additional unwanted errors
        }
        let ref: Ref = context.capture(binding: binding, node: self)
        return (LocatedRef(value: context.builder.buildCopy(value: LocatedRef(value: ref, node: self, binding: binding), type: binding.type), node: self), binding.type)
    }
}
