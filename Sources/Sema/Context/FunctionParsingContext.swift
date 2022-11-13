//
//  FunctionParsingContext.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 06/11/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

class FunctionParsingContext: ParsingContext {
    var function: Function
    var stack: [StackElement] = []
    
    init(parent: ParsingContext, function: Function) {
        self.function = function
        super.init(parent: parent)
    }
    
    func createFunction(name: String, type: FunctionType, source: Function.Source) -> Function {
        let fn = Function(parent: self.function, name: name, type: type, source: source)
        typeChecker.functions.append(fn)
        return fn
    }
}
