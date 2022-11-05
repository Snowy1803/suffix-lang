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

class GenericArchetype: NamedType {
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    func convertible(to other: SType) -> Bool {
        false // constrained generics are unsupported currently
    }
}

extension GenericArchetype {
    func with<T>(block: (GenericArchetype) -> T) -> T {
        block(self)
    }
}
