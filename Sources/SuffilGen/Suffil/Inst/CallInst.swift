//
//  CallInst.swift
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

final class CallInst {
    var returning: [LocatedLocalRef]
    var function: LocatedRef
    var parameters: [LocatedRef]
    
    init(returning: [LocatedLocalRef], function: LocatedRef, parameters: [LocatedRef]) {
        self.returning = returning
        self.function = function
        self.parameters = parameters
    }
}

extension CallInst: InstProtocol {
    var description: String {
        "(\(returning.map(\.description).joined(separator: ", "))) = call \(function) (\(parameters.map(\.description).joined(separator: ", ")))"
    }
    
    var definingRefs: [LocatedLocalRef] { returning }
    var usingRefs: [LocatedRef] { [function] + parameters }
    func replaceOccurrences(of target: Ref, with replacement: Ref) {
        function.value.replaceOccurrences(of: target, with: replacement)
        parameters.formMap {
            $0.value.replaceOccurrences(of: target, with: replacement)
        }
    }
    
    var isPure: Bool {
        // TODO: function should have pure/impure trait
        false
    }
}
