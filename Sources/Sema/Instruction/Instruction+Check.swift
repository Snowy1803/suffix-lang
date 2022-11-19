//
//  Instruction+Check.swift
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

extension Instruction {
    func registerTypeDeclaration(context: FunctionParsingContext) {
        switch self {
        case .record(let recordInstruction):
            recordInstruction.registerTypeDeclaration(context: context)
        case .push, .call, .bind, .function:
            break
        }
    }
    
    func registerGlobalBindings(context: FunctionParsingContext) {
        switch self {
        case .record(let recordInstruction):
            recordInstruction.registerGlobalBindings(context: context)
        case .function(let functionInstruction):
            functionInstruction.registerGlobalBindings(parent: context)
        case .push, .call, .bind:
            break
        }
    }
    
    func typecheckInstruction(context: FunctionParsingContext) {
        switch self {
        case .push(let pushInstruction):
            pushInstruction.buildInstruction(context: context)
        case .call(let callInstruction):
            break
        case .bind(let bindInstruction):
            bindInstruction.buildInstruction(context: context)
        case .function, .record:
            break
        }
    }
    
    func typecheckNestedFunctions(context: FunctionParsingContext) {
        switch self {
        case .function(let functionInstruction):
            let subcontext = functionInstruction.createSubContext(parent: context)
            functionInstruction.registerLocalBindings(subcontext: subcontext)
            functionInstruction.block.content.typecheckContent(context: subcontext)
        case .push, .call, .bind, .record:
            break
        }
    }
}
