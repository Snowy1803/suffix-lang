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

/// The UnresolvedType is a placeholder type, used inside function/type declarations and replaced with a concrete or placeholder when the function or type is actually used
class UnresolvedType: MappableType {
    let context: FunctionParsingContext
    
    init(context: FunctionParsingContext) {
        self.context = context
    }
    
    func convertible(to other: SType) -> Bool {
        for constraint in context.constraints {
            switch constraint {
            case .error:
                break
            case .convertible(let from, let to):
                if from === self {
                    // self convertible to `to`, `to` convertible to `other` => self convertible to other
                    return to.convertible(to: other)
                }
            case .functionType(let type, let argumentCount):
                if type === self {
                    if let other = other as? FunctionType {
                        if let argumentCount {
                            if other.variadicIndex == nil {
                                if argumentCount != other.arguments.count {
                                    return false
                                }
                            } else {
                                if argumentCount < other.arguments.count {
                                    return false
                                }
                            }
                        } else {
                            return true // maybe
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
        "unresolved type at \(ObjectIdentifier(self))"
    }
}
