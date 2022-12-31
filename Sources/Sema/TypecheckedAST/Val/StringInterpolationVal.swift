//
//  StringInterpolationVal.swift
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

public class StringInterpolationVal {
    public let input: [TStackElement]
    public let components: [Token.StringComponent]
    public let interpolationFunction: ReferenceVal
    public let interpolationFunctionType: SType
    public var type: SType // usually StringType
    public let source: Source
    
    init(input: [TStackElement], components: [Token.StringComponent], interpolationFunction: ReferenceVal, interpolationFunctionType: SType, type: SType, source: Source) {
        self.input = input
        self.components = components
        self.interpolationFunction = interpolationFunction
        self.interpolationFunctionType = interpolationFunctionType
        self.type = type
        self.source = source
    }
    
    public enum Source {
        case ast(StringValue)
        case builtin
    }
}

extension StringInterpolationVal: CustomStringConvertible {
    public var description: String {
        "\(components): \(type) # interpolation takes \(input.count) stack elements"
    }
}
