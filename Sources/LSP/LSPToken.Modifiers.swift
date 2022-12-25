//
//  LSPToken.Modifiers.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 25/12/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension LSPToken {
    struct Modifiers: OptionSet {
        let rawValue: UInt32
        static let declaration = Modifiers(rawValue: 1 << 0)
        static let definition = Modifiers(rawValue: 1 << 1)
        static let deprecated = Modifiers(rawValue: 1 << 2)
        static let defaultLibrary = Modifiers(rawValue: 1 << 3)
    }
}

extension LSPToken.Modifiers {
    static let legend = [
        "declaration",
        "definition",
        "deprecated",
        "defaultLibrary",
    ]
}
