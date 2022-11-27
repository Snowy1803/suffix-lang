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

class ClosurePass: TypeCheckingPass {
    var description: String { "Closure resolution" }
    
    func run(typechecker: TypeChecker) {
        for function in typechecker.functions {
            run(function: function, typechecker: typechecker)
        }
    }
    
    func run(function: Function, typechecker: TypeChecker) {
        for inst in function.instructions {
            if case .closure(let closureInst) = inst {
                run(closure: closureInst, typechecker: typechecker)
            } else {
                checkFunctionsAreConstant(inst: inst, typechecker: typechecker)
            }
        }
    }
    
    func run(closure inst: ClosureInst, typechecker: TypeChecker) {
        assert(inst.captures.isEmpty, "Closure resolution ran twice")
        for capture in inst.function.captures {
            inst.captures.append(capture.parentRef)
        }
    }
    
    func checkFunctionsAreConstant(inst: Inst, typechecker: TypeChecker) {
        for used in inst.wrapped.usingRefs {
            if case .function(let function) = used,
                !function.captures.isEmpty {
                typechecker.diagnostics.append(Diagnostic(tokens: [], message: .useFunctionWithCapturesBeforeDefinition(function.name), severity: .error))
            }
        }
    }
}
