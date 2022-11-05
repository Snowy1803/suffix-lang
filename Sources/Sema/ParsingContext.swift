//
//  ParsingContext.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 23/10/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

class ParsingContext {
    var parent: ParsingContext?
    var types: [NamedType] = []
    var bindings: [Binding] = []
    var stack: [StackElement] = []
    
    init(parent: ParsingContext?) {
        self.parent = parent
    }
    
    func getBindings(name: String) -> [Binding] {
        var result = parent?.getBindings(name: name) ?? []
        result.append(contentsOf: bindings.filter({ $0.name == name }))
        return result
    }
    
    struct Binding {
        var name: String
        var type: SType
        var source: Source
        
        enum Source {
            /// This value is an explicit binding (includes record field accessor functions)
            case binding(BindInstruction)
            /// This value is a named argument
            case argument(FunctionTypeReference.Argument)
            /// This value is a function
            case function(FunctionInstruction)
            /// This value is built in the language
            case builtin
        }
    }
    
    struct StackElement {
        var type: SType
        var source: Source
        
        enum Source {
            /// This value was pushed explicitly
            case push(PushInstruction)
            /// This value was returned by a function call
            case returnValue(CallInstruction)
            /// This value is an unnamed argument
            case argument(FunctionTypeReference.Argument)
        }
    }
}
