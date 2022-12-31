//
//  FunctionParsingContext+Constraint.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 28/12/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

class ConstraintContainer {
    
    var constraints: [Constraint] = []
    var unresolvedTypes: Set<UnresolvedType> = []
    var unresolvedBindings: Set<ReferenceVal> = []
    
    /// Creates a new type, that will have to be resolved later by constraint resolution
    func createUnresolvedType() -> UnresolvedType {
        let value = UnresolvedType(context: self)
        unresolvedTypes.insert(value)
        return value
    }
    
    func constrainFunctionType(type: SType, argumentCount: Int) {
        // always called with UnresolvedType from ReferenceVal
        constraints.append(.functionType(type, argumentCount: argumentCount))
    }
    
    func constrain(type: SType, convertibleTo other: SType) {
        if type === other {
            return
        }
        constraints.append(.convertible(from: type, to: other))
    }
    
    func computePossibleBindings(context: FunctionParsingContext, reference: ReferenceVal) -> [TBinding] {
        if let resolved = reference.resolvedBinding {
            return [resolved]
        }
        var bindings = context.getBindings(name: reference.name)
        bindings = bindings.filter({ $0.type.canBeAssigned(to: reference.type) })
        return bindings
    }
    
    func constrain(reference: ReferenceVal, oneOf bindings: [TBinding]) {
        if bindings.count == 1,
           let binding = bindings.first {
            reference.resolvedBinding = binding
            self.unresolvedBindings.remove(reference)
        } else {
            constraints.append(.possibleBindings(reference, possibilities: bindings))
        }
    }
    
    func resolveConstraints(statements: [Stmt]) -> [Stmt] {
        for constraint in constraints {
            print(constraint)
        }
//        for unresolvedType in unresolvedTypes {
//            var possibilities: [SType]?
//            for constraint in constraints {
//                switch constraint {
//                case .error:
//                    break
//                case .convertible(let from, let to):
//                    <#code#>
//                case .functionType(let sType, let argumentCount):
//                    <#code#>
//                case .possibleBindings(let referenceVal, let possibilities):
//                    <#code#>
//                }
//            }
//        }
        return statements
    }
    
    enum Constraint {
        /// There is a typechecking error
        case error(String)
        /// One type must be convertible to the other type
        case convertible(from: SType, to: SType)
        /// The type must be a function with a certain concrete number of arguments
        case functionType(SType, argumentCount: Int)
        /// The ReferenceVal's binding must be resolved in the given array of possibilities. The binding's type must be convertible to the reference's type
        case possibleBindings(ReferenceVal, possibilities: [TBinding])
    }
}
