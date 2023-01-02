//
//  ArrayType.swift
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

public final class ArrayType: NamedType {
    public var typeID: STypeID { .array }
    public var name: String { "array" }
    public var element: SType
    
    init(element: SType) {
        self.element = element
    }
    
    public var description: String {
        "\(name) [\(element)]"
    }
    
    public func convertible(to other: SType) -> Bool {
        guard let other = other as? ArrayType else {
            return false
        }
        return element.canBeAssigned(to: other.element)
    }
    
    public func map(with map: GenericMap) -> SType {
        ArrayType(element: element.map(with: map))
    }
}
