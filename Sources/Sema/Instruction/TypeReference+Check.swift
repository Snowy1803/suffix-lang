//
//  TypeReference+Check.swift
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

extension TypeReference {
    func resolve(context: ParsingContext) -> SType {
        switch self {
        case .function(let function):
            return FunctionType(generics: [], arguments: function.arguments.resolve(context: context), returning: function.returning.resolve(context: context))
        case .generic(let generic):
            // TODO: parameterize the generic type
            if let named = context.getType(name: generic.name.identifier) {
                return named
            }
            context.typeChecker.diagnostics.append(Diagnostic(tokens: generic.name.tokens, message: .unknownType(generic.name.identifier), severity: .error))
            return AnyType.shared
        }
    }
}
