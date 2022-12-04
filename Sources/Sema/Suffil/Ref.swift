//
//  Ref.swift
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
import SuffixLang

/// A reference to a previous instruction, for composition in `Inst`
enum Ref: Equatable {
    /// A ref to a function
    case function(Function)
    /// A value defined in another inst
    case local(LocalRef)
    /// An integer literal
    case intLiteral(Int)
    /// An float literal
    case floatLiteral(Double)
    /// A constant string literal
    case strLiteral(String)
}

extension Ref: CustomStringConvertible {
    var description: String {
        switch self {
        case .function(let function):
            return ".\(function.name): \(function.type)"
        case .local(let localRef):
            return localRef.description
        case .intLiteral(let integerValue):
            return "&\(integerValue): int"
        case .floatLiteral(let floatValue):
            return "&\(floatValue): float"
        case .strLiteral(let stringValue):
            return "&\(stringValue.debugDescription): str"
        }
    }
}

extension Ref {
    var isConstant: Bool {
        switch self {
        case .function(let function):
            // If the function hasn't been parsed yet, the captures will always be empty
            // If there is captures, an error will be raised in ClosurePass
            return function.captures.isEmpty
        case .local:
            return false
        case .intLiteral, .floatLiteral, .strLiteral:
            return true
        }
    }
}
