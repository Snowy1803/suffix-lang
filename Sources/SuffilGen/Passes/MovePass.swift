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

class MovePass: SuffilPass {
    var description: String { "Unnecessary copies elimination" }
    
    func run(generator: SuffilGenerator) {
        for function in generator.functions {
            run(function: function, generator: generator)
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
    func run(function: Function, generator: SuffilGenerator) {
        var copies: [CopyInst] = []
        var instsToRemove: Set<ObjectIdentifier> = []
        var copiesToReplaceInOrder: [CopyInst] = []
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
                    instsToRemove.insert(ObjectIdentifier(copy))
                    copiesToReplaceInOrder.append(copy)
                    instsToRemove.insert(ObjectIdentifier(destroyInst))
                }
            default:
                removeUsed()
            }
        }
        function.instructions.removeAll { inst in
            instsToRemove.contains(ObjectIdentifier(inst.wrapped))
        }
        function.instructions.forEach { inst in
            for copy in copiesToReplaceInOrder.reversed() {
                inst.wrapped.replaceOccurrences(of: .local(copy.copy.value), with: copy.original.value)
            }
        }
    }
}

