//
//  RetInst.swift
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

final class RetInst {
    var values: [LocatedRef]
    
    init(values: [LocatedRef]) {
        self.values = values
    }
}

extension RetInst: InstProtocol {
    var description: String {
        "ret (\(values.map(\.description).joined(separator: ", ")))"
    }
    
    var definingRefs: [LocatedLocalRef] { [] }
    var usingRefs: [LocatedRef] { values }
    func replaceOccurrences(of target: Ref, with replacement: Ref) {
        values.formMap {
            $0.value.replaceOccurrences(of: target, with: replacement)
        }
    }
}
