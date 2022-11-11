//
//  SType.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 22/10/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public protocol SType: AnyObject {
    /// Returns true if this type can be converted to the different type `other`
    /// This function need not return true if the types are the same or if the other type is `any`,
    /// as this is handled in `canBeAssigned(to:)`
    /// This function should not be called directly, use `canBeAssigned(to:)`
    func convertible(to other: SType) -> Bool
}

public protocol NamedType: SType {
    var name: String { get }
}

public protocol LeafType: SType {
    
}

extension LeafType {
    public func convertible(to other: SType) -> Bool {
        false
    }
}

extension SType {
    func canBeAssigned(to type: SType) -> Bool {
        if self === type {
            return true
        }
        if type is AnyType {
            return true
        }
        // we may need a type.canWrap(other: self) for optionals and move the condition for any
        return self.convertible(to: type)
    }
}
