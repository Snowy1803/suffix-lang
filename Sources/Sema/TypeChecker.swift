//
//  TypeChecker.swift
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

public class TypeChecker {
    var builtinContext = BuiltinParsingContext.shared
    var rootContext: RootParsingContext?
    var rootBlock: BlockContent
    var diagnostics: [Diagnostic] = []
    
    init(rootBlock: BlockContent) {
        self.rootBlock = rootBlock
        self.rootContext = RootParsingContext(typechecker: self, builtins: builtinContext)
    }
    
    func typecheck() {
        
    }
}
