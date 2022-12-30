//
//  ClosurePass.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 27/11/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

class ClosurePass: SuffilPass {
    var description: String { "Closure resolution" }
    
    func run(generator: SuffilGenerator) {
        for function in generator.functions {
            run(function: function, generator: generator)
        }
    }
    
    func run(function: Function, generator: SuffilGenerator) {
        for inst in function.instructions {
            if case .closure(let closureInst) = inst {
                run(closure: closureInst, generator: generator)
            }
        }
    }
    
    func run(closure inst: ClosureInst, generator: SuffilGenerator) {
        assert(inst.captures.isEmpty, "Closure resolution ran twice")
        for capture in inst.function.value.captures {
            inst.captures.append(LocatedRef(value: capture.parentRef, binding: capture.binding))
        }
    }
}
