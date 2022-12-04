//
//  ObjectID.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 04/12/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

struct ObjectID<T> where T: AnyObject {
    private var id: ObjectIdentifier
    
    init(_ value: T) {
        self.id = ObjectIdentifier(value)
    }
}

extension ObjectID: Equatable, Hashable {}
