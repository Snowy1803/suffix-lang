//
//  LocalRef.swift
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

class LocalRef {
    let givenName: String
    let type: SType
    
    init(givenName: String, type: SType) {
        self.givenName = givenName
        self.type = type
    }
}

extension LocalRef: CustomStringConvertible {
    var description: String {
        "%\(givenName): \(type)"
    }
}
