//
//  ASTNode.swift
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

public protocol ASTNode {
    var nodeType: String { get }
    var nodeData: String? { get }
    var nodeChildren: [ASTElement] { get }
}

public extension ASTNode {
    var nodeType: String {
        String(describing: type(of: self))
    }
    
    var nodeData: String? {
        nil
    }
}

public struct ASTElement {
    public var name: String
    public var value: [ASTNode]
}

extension ASTElement {
    init(name: String, value: ASTNode?) {
        self.init(name: name, value: value.map { [$0] } ?? [])
    }
}

protocol SingleTokenASTNode: ASTNode {
    var token: Token { get }
}

extension SingleTokenASTNode {
    var nodeData: String? { token.data.debugDescription }
    var nodeChildren: [ASTElement] { [] }
}
