//
//  Located.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 01/12/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

typealias LocatedRef = Located<Ref>
typealias LocatedLocalRef = Located<LocalRef>
typealias LocatedFunction = Located<Function>
typealias LocationInfo = Located<Void>

struct Located<RefType> {
    /// The wrapped ref
    var value: RefType
    /// The AST node where this ref was found. It contains the location information
    var node: ASTNode?
    /// The binding this value is referring to, if applicable
    var binding: Binding?
    /// The stack element this value is referring to, if applicable
    var stackElement: StackElement?
}

extension Located: CustomStringConvertible where RefType: CustomStringConvertible {
    var description: String {
        value.description
    }
}

extension Located {
    func map<T>(_ transform: (RefType) throws -> T) rethrows -> Located<T> {
        Located<T>(value: try transform(value), node: node, binding: binding, stackElement: stackElement)
    }
}

extension Ref {
    var noLocation: Located<Ref> { Located(value: self) }
}
extension LocalRef {
    var noLocation: Located<LocalRef> { Located(value: self) }
}
extension Function {
    var noLocation: Located<Function> { Located(value: self) }
}
