//
//  SpecialiseInst.swift
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

final class SpecialiseInst {
    var name: LocatedLocalRef
    var function: LocatedRef
    var types: [SType]
    
    init(name: LocatedLocalRef, function: LocatedRef, types: [SType]) {
        self.name = name
        self.function = function
        self.types = types
    }
}

extension SpecialiseInst: InstProtocol {
    var description: String {
        "\(name) = specialise \(function) [\(types.map(\.description).joined(separator: ", "))]"
    }
    
    var definingRefs: [LocatedLocalRef] { [name] }
    var usingRefs: [LocatedRef] { [function] }
    func replaceOccurrences(of target: Ref, with replacement: Ref) {
        function.value.replaceOccurrences(of: target, with: replacement)
    }
}
