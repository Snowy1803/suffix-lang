//
//  ConstantStringVal.swift
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

public class ConstantStringVal {
    public let value: String
    public var type: SType // usually StringType
    public let source: Source
    
    init(value: String, type: SType, source: Source) {
        self.value = value
        self.type = type
        self.source = source
    }
    
    public enum Source {
        case ast(StringValue)
        case builtin
    }
}

extension ConstantStringVal: CustomStringConvertible {
    public var description: String {
        "\(value.debugDescription): \(type)"
    }
}
