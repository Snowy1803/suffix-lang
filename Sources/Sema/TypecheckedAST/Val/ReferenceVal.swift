//
//  ReferenceVal.swift
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
import SuffixLang

public class ReferenceVal {
    public let name: String
    public var type: SType
    public let source: Source
    public var resolvedBinding: TBinding?
    
    init(name: String, type: SType, source: Source) {
        self.name = name
        self.type = type
        self.source = source
    }
    
    public enum Source {
        case ast(ReferenceValue)
    }
}