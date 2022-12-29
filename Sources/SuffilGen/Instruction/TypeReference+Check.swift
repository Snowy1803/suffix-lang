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
            let type = FunctionType(generics: [], arguments: function.arguments.resolve(context: context), returning: function.returning.resolve(context: context), traits: TraitContainer(type: .func, source: false, traits: function.traits?.createContainer(context: context) ?? [], diagnostics: &context.typeChecker.diagnostics))
            context.typeChecker.logger.log(.functionTypeReferenced(type, function))
            return type
        case .generic(let generic):
            guard let named = context.getType(name: generic.name.identifier) else {
                context.typeChecker.diagnostics.append(Diagnostic(tokens: generic.name.tokens, message: .unknownType(generic.name.identifier), severity: .error))
                return AnyType.shared
            }
            context.typeChecker.logger.log(.namedTypeReferenced(named, generic))
            let generics = named.genericArchetypesInDefinition
            guard generics.count == generic.generics?.generics.count ?? 0 else {
                if let node = generic.generics {
                    context.typeChecker.diagnostics.append(Diagnostic(tokens: node.nodeAllTokens, message: .genericTypeParameterCountInvalid(expected: generics.count, actual: node.generics.count), severity: .error))
                } else {
                    context.typeChecker.diagnostics.append(Diagnostic(tokens: generic.name.tokens, message: .genericTypeParameterMissing(expected: generics.count), severity: .error))
                }
                return named // invalid
            }
            let map = GenericMap(map: Dictionary(uniqueKeysWithValues: zip(generics, generic.generics?.generics ?? []).map { archetype, parameter in
                let resolved = parameter.type.resolve(context: context)
                return (ObjectID(archetype), resolved)
            }))
            return named.map(with: map)
        }
    }
}
