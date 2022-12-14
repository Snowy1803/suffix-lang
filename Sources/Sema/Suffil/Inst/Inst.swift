//
//  Inst.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 12/11/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

/// A suffil instruction
enum Inst {
    /// A call to a function
    case call(CallInst)
    /// A return, at the end of the function
    case ret(RetInst)
    /// The specialisation of a generic function
    case specialise(SpecialiseInst)
    /// Create an array (for variadic functions usually)
    case array(ArrayInst)
    /// Copy a value (retain if reference counting is needed, otherwise no op)
    case copy(CopyInst)
    /// Capture some bindings to put into a closure
    case closure(ClosureInst)
    /// Destroys a value (release if reference counted, otherwise no op)
    case destroy(DestroyInst)
}

protocol InstProtocol: AnyObject, CustomStringConvertible {
    var definingRefs: [LocatedLocalRef] { get }
    var usingRefs: [LocatedRef] { get }
    func replaceOccurrences(of target: Ref, with replacement: Ref)
}

extension Inst {
    var wrapped: InstProtocol {
        switch self {
        case .call(let inst as InstProtocol),
             .ret(let inst as InstProtocol),
             .specialise(let inst as InstProtocol),
             .array(let inst as InstProtocol),
             .copy(let inst as InstProtocol),
             .closure(let inst as InstProtocol),
             .destroy(let inst as InstProtocol):
            return inst
        }
    }
}

extension MutableCollection {
    mutating func formMap(_ body: (inout Element) throws -> Void) rethrows {
        for index in indices {
            try body(&self[index])
        }
    }
}
