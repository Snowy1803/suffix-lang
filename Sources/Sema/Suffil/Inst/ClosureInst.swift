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
    let name: LocalRef
    let function: Ref
    var captures: [Ref] = []
    
    init(name: LocalRef, function: Ref) {
        self.name = name
        self.function = function
    }
}

extension ClosureInst: InstProtocol {
    var description: String {
        "\(name) = closure \(function) (\(captures.map(\.description).joined(separator: ", ")))"
    }
    
    var definingRefs: [LocalRef] { [name] }
    var usingRefs: [Ref] { [function] + captures }
}
