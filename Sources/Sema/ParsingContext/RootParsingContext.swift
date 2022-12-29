//
//  RootParsingContext.swift
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

class RootParsingContext: FunctionParsingContext {
    unowned var typechecker: TypeChecker
    
    init(typechecker: TypeChecker, builtins: ParsingContext) {
        self.typechecker = typechecker
        let function = TFunction(parent: nil, name: "main", type: FunctionType(arguments: [], returning: [], traits: TraitContainer(type: .func, source: false, builtin: [])), content: .main, traits: TraitContainer(type: .func, source: true, builtin: []))
        super.init(parent: builtins, function: function)
    }
    
    override var typeChecker: TypeChecker! {
        typechecker
    }
}
