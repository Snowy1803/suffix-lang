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

class CallInst {
    let returning: [LocalRef]
    let function: Ref
    let parameters: [Ref]
    
    init(returning: [LocalRef], function: Ref, parameters: [Ref]) {
        self.returning = returning
        self.function = function
        self.parameters = parameters
    }
}

extension CallInst: InstProtocol {
    var description: String {
        "(\(returning.map(\.description).joined(separator: ", "))) = call \(function) (\(parameters.map(\.description).joined(separator: ", ")))"
    }
    
    var definingRefs: [LocalRef] { returning }
    var usingRefs: [Ref] { [function] + parameters }
}
