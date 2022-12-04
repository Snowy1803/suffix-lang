//
//  MovePass.swift
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

class MovePass: TypeCheckingPass {
    var description: String { "Unnecessary copies elimination" }
    
    func run(typechecker: TypeChecker) {
        for function in typechecker.functions {
            run(function: function, typechecker: typechecker)
        }
    }
    /// Runs the Unnecessary copies elimination, replacing copy+destroy to a move
    ///
    /// Detects the following patterns:
    ///
    /// ```suffil
    /// %1 = copy %0
    /// () = call .smth (%1)
    /// destroy %0
    /// ```
    ///
    /// And replaces it with:
    ///
    /// ```suffil
    /// () = call .smth (%0)
    /// ```
    func run(function: Function, typechecker: TypeChecker) {
        var copies: [CopyInst] = []
        var copiesToReplace: Set<ObjectIdentifier> = []
        var destroysToRemove: Set<ObjectIdentifier> = []
        for inst in function.instructions {
            func removeUsed() {
                for used in inst.wrapped.usingRefs {
                    copies.removeAll(where: { $0.original.value == used.value })
                }
            }
            switch inst {
            case .copy(let copyInst):
                removeUsed()
                copies.append(copyInst)
            case .destroy(let destroyInst):
                if let copyIndex = copies.firstIndex(where: { destroyInst.value.value == $0.original.value }) {
                    let copy = copies.remove(at: copyIndex)
                    // replace the copy with the original, making it into a 'move' operation
                    copiesToReplace.insert(ObjectIdentifier(copy))
                    destroysToRemove.insert(ObjectIdentifier(destroyInst))
                }
            default:
                removeUsed()
            }
        }
        function.instructions = function.instructions.compactMap { inst in
            if case .copy(let copyInst) = inst,
               copiesToReplace.contains(ObjectIdentifier(copyInst)) {
                // replace the copy with a rename
                return .rename(RenameInst(newName: copyInst.copy, oldName: copyInst.original))
            }
            if case .destroy(let destroyInst) = inst,
               destroysToRemove.contains(ObjectIdentifier(destroyInst)) {
                return nil // remove the destroy
            }
            return inst
        }
    }
}

