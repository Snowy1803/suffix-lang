//
//  PushStmt.swift
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

public class PushStmt {
    public let element: TStackElement
    public let source: PushInstruction
    
    init(element: TStackElement, source: PushInstruction) {
        self.element = element
        self.source = source
    }
}

extension PushStmt: CustomStringConvertible {
    public var description: String {
        "&\(element.value)"
    }
}
