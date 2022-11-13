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
    /// The type check is two stages: first, resolve and create functions and records (global stuff),
    /// then, resolve and create insts
    /// This function executes the first stage, and returns a function that executes the second
    func typeCheck(context: FunctionParsingContext) -> () -> Void {
        switch self {
        case .push(_):
            // TODO: implement
            break
        case .call(_):
            // TODO: implement
            break
        case .bind(_):
            // TODO: implement
            break
        case .function(let function):
            let subcontext = function.createSubContext(parent: context)
            let next = function.block.content.instructions.map { inst in
                inst.typeCheck(context: subcontext)
            }
            return {
                next.forEach {
                    $0()
                }
            }
        case .record(let record):
            record.resolve(context: context)
            return {} // nothing to do
        }
        return {} // not implemented
    }
}
