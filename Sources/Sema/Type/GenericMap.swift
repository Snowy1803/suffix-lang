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

public struct GenericMap {
    var map: [ObjectID<GenericArchetype>: SType]
    
    func apply(type: GenericArchetype) -> SType {
        if let mapped = map[ObjectID(type)] {
            return mapped
        }
        return type
    }
    
    func contains(type: GenericArchetype) -> Bool {
        map.keys.contains(ObjectID(type))
    }
}
