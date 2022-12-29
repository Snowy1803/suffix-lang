//
//  TStackElement.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 27/12/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

public class TStackElement {
    public let value: Val
    public var source: Source
    
    init(value: Val, source: Source) {
        self.value = value
        self.source = source
    }
    
    public enum Source {
        case push(PushInstruction)
        case call(CallInstruction)
        case argument(FunctionTypeReference.Argument)
        
        var node: ASTNode {
            switch self {
            case .push(let node as ASTNode),
                 .call(let node as ASTNode),
                 .argument(let node as ASTNode):
                return node
            }
        }
    }
}
