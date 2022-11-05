//
//  FunctionType.swift
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
import SuffixLang

public class FunctionType: SType {
    public var arguments: [Argument]
    public var returning: [Argument]
    
    init(arguments: [Argument], returning: [Argument]) {
        self.arguments = arguments
        self.returning = returning
    }
    
    public struct Argument {
        public var type: SType
        public var variadic: Bool = false
    }
}
