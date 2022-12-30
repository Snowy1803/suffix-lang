//
//  ReferenceHashable.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 30/12/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

public protocol ReferenceHashable: AnyObject, Equatable, Hashable {
    
}

extension ReferenceHashable {
    public static func ==(_ lhs: Self, _ rhs: Self) -> Bool {
        lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
