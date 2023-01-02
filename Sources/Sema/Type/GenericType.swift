//
//  GenericType.swift
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
import SuffixLang

/// A type used in declarations to hold generic archetypes. Currently only used for functions and arrays
public class GenericType: SType, NamedType {
    public var typeID: STypeID { .generic }
    let generics: [GenericArchetype]
    
    public let wrapped: SType
    
    init(generics: [GenericArchetype], wrapped: SType) {
        self.generics = generics
        self.wrapped = wrapped
    }
    
    public func map(with map: GenericMap) -> SType {
        let remaining = generics.filter { !map.contains(type: $0) }
        if remaining.count == 0 {
            return wrapped.map(with: map)
        } else {
            return GenericType(generics: remaining, wrapped: wrapped.map(with: map))
        }
    }
    
    public var description: String {
        return "[\(generics.map(\.description).joined(separator: ", "))] \(wrapped)"
    }
    
    public func convertible(to other: SType) -> Bool {
        false // illegal
    }
    
    public var name: String {
        if let wrapped = wrapped as? NamedType {
            return wrapped.name
        } else {
            preconditionFailure()
        }
    }
}
