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
    public var literal: Identifier
    public var typeAnnotation: TypeAnnotation?
}

public struct TakenArgumentCount: ASTNode {
    public var open: Token
    public var count: IntegerValue
    public var close: Token
}
