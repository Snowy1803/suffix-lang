//
//  BindStmt.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 22/10/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

public class BindStmt {
    public let binding: TBinding
    public let source: BindInstruction
    
    init(binding: TBinding, source: BindInstruction) {
        self.binding = binding
        self.source = source
    }
}

extension BindStmt: CustomStringConvertible {
    public var description: String {
        "> \(binding.name): \(binding.type)"
    }
}
