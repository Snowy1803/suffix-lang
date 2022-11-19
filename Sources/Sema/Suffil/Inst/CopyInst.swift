//
//  CopyInst.swift
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

class CopyInst {
    let copy: LocalRef
    let original: Ref
    
    init(copy: LocalRef, original: Ref) {
        self.copy = copy
        self.original = original
    }
}

extension CopyInst: InstProtocol {
    var description: String {
        "\(copy) = copy \(original)"
    }
    
    var definingRefs: [LocalRef] { [copy] }
}
