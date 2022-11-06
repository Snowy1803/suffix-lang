//
//  ReferenceValue.swift
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

public struct ReferenceValue: ASTNode {
    public var identifier: TypedIdentifier
    public var generics: GenericTypeArguments?
    public var argumentCount: TakenArgumentCount?
}

public struct TypedIdentifier: ASTNode {
    public var literal: Token
    public var typeAnnotation: TypeAnnotation?
}

public extension Token {
    var identifier: String {
        if case .identifier(let id) = data {
            return id
        }
        // happens in the case of a synthesized missing token
        return literal.description
    }
}

public struct TakenArgumentCount: ASTNode {
    public var open: Token
    public var count: IntegerValue
    public var close: Token
}
