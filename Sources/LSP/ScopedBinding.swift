//
//  ScopedBinding.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 20/12/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang
import Sema
import LanguageServerProtocol

struct ScopedBinding {
    /// Start of scope, inclusive, nil if infinite
    var start: TokenPosition?
    /// End of scope, exclusive, nil if infinite
    var end: TokenPosition?
    var binding: Binding
}

extension ScopedBinding {
    func isInScope(at pos: Position) -> Bool {
        if let start,
           start.lsp > pos {
            return false
        }
        if let end,
           end.lsp <= pos {
            return false
        }
        return true
    }
}
