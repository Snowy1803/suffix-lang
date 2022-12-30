//
//  ArgumentVal.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 29/12/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

public class ArgumentVal {
    public let function: TFunction
    public let index: Int
    public var type: SType
    public var source: FunctionTypeReference.Argument
    
    init(function: TFunction, index: Int, type: SType, source: FunctionTypeReference.Argument) {
        self.function = function
        self.index = index
        self.type = type
        self.source = source
    }
}

extension ArgumentVal: CustomStringConvertible {
    public var description: String {
        "@argument(\(function.name), \(index)): \(type)"
    }
}
