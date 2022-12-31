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
    func buildValue(context: FunctionParsingContext) -> ReferenceVal {
        let type = identifier.typeAnnotation?.type.resolve(context: context)
        let ref = ReferenceVal(name: identifier.literal.identifier, type: type ?? context.constraints.createUnresolvedType(), source: .ast(self))
        context.constraints.unresolvedBindings.insert(ref)
        if let count = self.argumentCount?.count.integer {
            context.constraints.constrainFunctionType(type: ref.type, argumentCount: count)
        }
        context.constraints.constrain(reference: ref, oneOf: context.constraints.computePossibleBindings(context: context, reference: ref))
        return ref
    }
}

extension StringValue {
    func createStringInterpolationFunctionRef(name: String, type: SType, context: FunctionParsingContext) -> ReferenceVal {
        let ref = ReferenceVal(name: name, type: type, source: .stringInterpolationFunction(self))
        context.constraints.unresolvedBindings.insert(ref)
        context.constraints.constrain(reference: ref, oneOf: context.constraints.computePossibleBindings(context: context, reference: ref))
        return ref
    }
}
