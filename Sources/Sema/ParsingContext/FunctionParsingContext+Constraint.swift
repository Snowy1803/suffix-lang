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

extension FunctionParsingContext {
    /// Creates a new type, that will have to be resolved later by constraint resolution
    func createUnresolvedType() -> UnresolvedType {
        let value = UnresolvedType(context: self)
        unresolvedTypes.append(value)
        return value
    }
    
    func constrainFunctionType(type: SType) {
        if type is FunctionType {
            // no op
        } else {
            constraints.append(.functionType(type, argumentCount: nil))
        }
    }
    
    func constrainFunctionType(type: SType, argumentCount: Int) {
        // always called with UnresolvedType from ReferenceVal
        constraints.append(.functionType(type, argumentCount: argumentCount))
    }
    
    func constrain(type: SType, convertibleTo other: SType) {
        constraints.append(.convertible(from: type, to: other))
    }
    
    func computePossibleBindings(reference: ReferenceVal) -> [TBinding] {
        if let resolved = reference.resolvedBinding {
            return [resolved]
        }
        var bindings = self.getBindings(name: reference.name)
        bindings = bindings.filter({ $0.type.canBeAssigned(to: reference.type) })
        return bindings
    }
    
    enum Constraint {
        case error(String)
        case convertible(from: SType, to: SType)
        case functionType(SType, argumentCount: Int?)
    }
}
