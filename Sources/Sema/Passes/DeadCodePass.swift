//
//  DeadCodePass.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 03/12/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

class DeadCodePass: TypeCheckingPass {
    var description: String { "Dead code elimination" }
    
    func run(typechecker: TypeChecker) {
        for function in typechecker.functions {
            run(function: function, typechecker: typechecker)
        }
    }
    
    func run(function: Function, typechecker: TypeChecker) {
        var uses: [ObjectIdentifier: Int] = [:]
        for inst in function.instructions {
            for def in inst.wrapped.definingRefs {
                if case .call(let callInst) = inst,
                   !callInst.isPure {
                    continue // impure calls can never be removed
                }
                uses[ObjectIdentifier(def.value)] = 0
            }
            for used in inst.wrapped.usingRefs {
                if case .destroy = inst {
                    continue // a destroy isn't really a 'use'
                }
                if case .local(let local) = used.value {
                    uses[ObjectIdentifier(local)]? += 1
                }
            }
        }
        let toRemove = uses.compactMap({ id, count -> ObjectIdentifier? in
            if count == 0 {
                return id
            } else {
                return nil
            }
        })
        function.instructions = function.instructions.filter { inst in
            !(
                inst.wrapped.usingRefs.contains(where: { usedRef in
                    toRemove.contains(where: { usedRef.value.isEqualTo(localId: $0) })
                }) || inst.wrapped.definingRefs.contains(where: { usedRef in
                    toRemove.contains(where: { ObjectIdentifier(usedRef.value) == $0 })
                })
            )
        }
    }
}

extension Ref {
    func isEqualTo(localId: ObjectIdentifier) -> Bool {
        if case .local(let current) = self {
            return ObjectIdentifier(current) == localId
        }
        return false
    }
}
