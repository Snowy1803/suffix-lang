//
//  TypeCheckDiagnosticMessage.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 06/11/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

enum TypeCheckDiagnosticMessage: DiagnosticMessage {
    case negativeArgumentCount(IntegerValue)
    case unknownType(String)
    case missingTypeAnnotation
    
    var description: String {
        switch self {
        case .negativeArgumentCount(let token):
            return "Invalid argument multiplier: \(token.integer) is negative"
        case .unknownType(let name):
            return "Could not find type '\(name)' in scope"
        case .missingTypeAnnotation:
            return "Missing type annotation"
        }
    }
}
