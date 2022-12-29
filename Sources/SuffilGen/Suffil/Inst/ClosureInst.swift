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

final class ClosureInst {
    var name: LocatedLocalRef
    var function: LocatedFunction
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
    func replaceOccurrences(of target: Ref, with replacement: Ref) {
        // note: the function cannot be replaced as it is not a real ref, its always a function
        // it should never be an issue
        captures.formMap {
            $0.value.replaceOccurrences(of: target, with: replacement)
        }
    }
}
