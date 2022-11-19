//
//  BlockContent+Check.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 19/11/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

extension BlockContent {
    /// The type checker acts in multiple passes:
    /// - parse type declarations
    /// - parse global bindings (type fields and function signatures)
    /// - parse instructions
    /// - typecheck the content of nested functions recursively
    func typecheckContent(context: FunctionParsingContext) {
        instructions.forEach {
            $0.registerTypeDeclaration(context: context)
        }
        instructions.forEach {
            $0.registerGlobalBindings(context: context)
        }
        instructions.forEach {
            $0.typecheckInstruction(context: context)
        }
        instructions.forEach {
            $0.typecheckNestedFunctions(context: context)
        }
    }
}
