//
//  AnonymousFunctionValue+Build.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 28/12/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

extension AnonymousFunctionValue {
    func buildValue(context: FunctionParsingContext) -> Val {
        let val = buildPartialValue(context: context)
        let subcontext = val.createAnonymousFunctionContext(parent: context)
        val.source.arguments.registerLocalBindings(subcontext: subcontext)
        val.content = block.content.typecheckContent(context: subcontext)
        return .anonymousFunc(val)
    }
}
