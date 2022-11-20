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
    var nodePosition: TokenPosition? { get }
    var nodeChildren: [ASTElement] { get }
    var nodeAllTokens: [Token] { get }
}

public protocol ASTEnum: ASTNode {
    var node: ASTNode { get } // unused
}

public protocol ASTArray {
    var nodes: [ASTNode] { get }
}

public extension ASTNode {
    var nodeType: String {
        String(describing: type(of: self))
    }
    
    var nodeData: String? {
        nil
    }
    
    var nodePosition: TokenPosition? {
        nil
    }
    
    var nodeChildren: [ASTElement] {
        let mirror = Mirror(reflecting: self)
        var result: [ASTElement] = []
        for (label, value) in mirror.children {
            switch value {
            case let node as ASTNode:
                result.append(ASTElement(name: label ?? "unnamed", value: node))
            case let node as ASTNode?:
                result.append(ASTElement(name: label ?? "unnamed", value: node))
            case let array as ASTArray:
                result.append(ASTElement(name: label ?? "unnamed", value: array.nodes))
            default:
                print("unknown type: \(type(of: value))")
                break
            }
        }
        return result
    }
    
    var nodeAllTokens: [Token] {
        nodeChildren.flatMap(\.value).flatMap(\.nodeAllTokens)
    }
}

extension Token: ASTNode {
    public var nodeType: String {
        "\(type)"
    }
    
    public var nodeData: String? {
        if let data = data {
            return "\(data)"
        } else {
            return literal.debugDescription
        }
    }
    
    public var nodePosition: TokenPosition? {
        position
    }
    
    public var nodeChildren: [ASTElement] { [] }
    public var nodeAllTokens: [Token] { [self] }
}

extension Array: ASTArray where Element: ASTNode {
    public var nodes: [ASTNode] {
        self
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
