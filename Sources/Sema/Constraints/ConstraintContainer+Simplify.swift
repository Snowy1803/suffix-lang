//
//  ConstraintContainer+Simplify.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 03/01/2023.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension ConstraintContainer {
    func simplify(constraint: Constraint) -> Bool {
        switch constraint {
        case .error(let string):
            // shouldn't happen
            return false
        case .convertible(let from, let to):
            <#code#> // TODO: simplify arrays etc
        case .functionType(let sType, let argumentCount):
            if let ftype = sType as? FunctionType, ftype.arguments.count == argumentCount {
                return true // already OK
            }
            return false
        case .possibleBindings(let referenceVal, let possibilities):
            return false // TODO: resolve binding if possibilities.count == 1
        }
    }
}
