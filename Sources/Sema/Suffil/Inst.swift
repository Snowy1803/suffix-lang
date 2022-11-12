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
    /// A binding usually
    case rename(RenameInst)
    /// A return, at the end of the function
    case ret(RetInst)
}

protocol InstProtocol: AnyObject, CustomStringConvertible {
    var definingRefs: [LocalRef] { get }
}

extension Inst {
    var wrapped: InstProtocol {
        switch self {
        case .call(let inst as InstProtocol),
             .rename(let inst as InstProtocol),
             .ret(let inst as InstProtocol):
            return inst
        }
    }
}
