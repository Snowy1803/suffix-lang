//
//  GenericArchetype.swift
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

/// The GenericArchetype is a generic placeholder type, used inside function/type declarations and replaced with a concrete or placeholder when the function or type is actually used
public class GenericArchetype: NamedType, MappableType {
    public var name: String
    
    public init(name: String) {
        self.name = name
    }
    
    public func convertible(to other: SType) -> Bool {
        false // constrained generics are unsupported currently
    }
    
    public func map(with map: GenericMap) -> SType {
        map.apply(type: self)
    }
    
    public var genericArchetypesInDefinition: [GenericArchetype] { [] }
}

extension GenericArchetype {
    func with<T>(block: (GenericArchetype) -> T) -> T {
        block(self)
    }
}
