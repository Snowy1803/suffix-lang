//
//  UnresolvedType.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 05/11/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// The UnresolvedType is a type variable, used during typechecking until the type inference has found the correct type
class UnresolvedType: MappableType, ReferenceHashable {
    public var typeID: STypeID { .variable }
    let context: ConstraintContainer
    
    init(context: ConstraintContainer) {
        self.context = context
    }
    
    func convertible(to other: SType) -> Bool {
        for constraint in context.constraints {
            switch constraint {
            case .error, .possibleBindings:
                break
            case .convertible(let from, let to):
                if from === self {
                    // self convertible to `to`, `to` convertible to `other` => self convertible to other
                    return to.convertible(to: other)
                }
            case .functionType(let type, let argumentCount):
                if type === self {
                    if let other = other as? FunctionType {
                        if other.variadicIndex == nil {
                            if argumentCount != other.arguments.count {
                                return false
                            }
                        } else {
                            if argumentCount < other.arguments.count {
                                return false
                            }
                        }
                    } else if other is UnresolvedType {
                        return true // maybe
                    } else {
                        return false
                    }
                }
            }
        }
        return true // we don't know, so maybe
    }
    
    func map(with map: GenericMap) -> SType {
        map.apply(type: self)
    }
    
    var genericArchetypesInDefinition: [GenericArchetype] { [] }
}

extension UnresolvedType: CustomStringConvertible {
    var description: String {
        "unresolved type at \(ObjectIdentifier(self).debugDescription.dropFirst("ObjectIdentifier(".count).dropLast())"
    }
}
