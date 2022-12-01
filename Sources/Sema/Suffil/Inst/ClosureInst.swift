//
//  ClosureInst.swift
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

class ClosureInst {
    let name: LocatedLocalRef
    let function: LocatedFunction
    var captures: [LocatedRef] = []
    
    var functionRef: LocatedRef { function.map({ .function($0) }) }
    
    init(name: LocatedLocalRef, function: LocatedFunction) {
        self.name = name
        self.function = function
    }
}

extension ClosureInst: InstProtocol {
    var description: String {
        "\(name) = closure \(functionRef) (\(captures.map(\.description).joined(separator: ", ")))"
    }
    
    var definingRefs: [LocatedLocalRef] { [name] }
    var usingRefs: [LocatedRef] { [functionRef] + captures }
}
