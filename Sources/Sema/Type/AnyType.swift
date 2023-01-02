//
//  AnyType.swift
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

public final class AnyType: NamedType, LeafType {
    public var typeID: STypeID { .any }
    public var name: String { "any" }
    
    public static let shared = AnyType()
    private init() {}
}
