//
//  GenericMap.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 11/11/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

protocol MappableType: SType {}

public struct GenericMap {
    var map: [ObjectIdentifier: SType]
    
    func apply(type: some MappableType) -> SType {
        if let mapped = map[ObjectIdentifier(type)] {
            return mapped
        }
        return type
    }
    
    func contains(type: some MappableType) -> Bool {
        map.keys.contains(ObjectIdentifier(type))
    }
}
