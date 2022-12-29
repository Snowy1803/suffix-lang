//
//  TBinding.swift
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

public final class TBinding {
    /// The name of the binding
    public let name: String
    /// The type of the value (which also helps between overloads)
    public let type: SType
    /// The source mapping for this binding, for diagnostics
    public let source: Source
    /// The element it was created with
    public let content: Content
    
    init(name: String, type: SType, source: Source, content: Content) {
        self.name = name
        self.type = type
        self.source = source
        self.content = content
    }
    
    public enum Content {
        /// This value is an explicit binding of an original stack element
        case element(TStackElement)
        /// This value is builtin or synthesized, and has this value
        case builtin(Val)
        /// This value is a function from a statement
        case function(TFunction)
        /// This value is a named argument
        case argument(ArgumentVal)
        /// This value is builtin or synthesized function
        case builtinFunction
        /// This binding is errored and has no value
        case error
    }
    
    public enum Source {
        /// This value is an explicit binding
        case binding(BindInstruction)
        /// This value is a named argument
        case argument(FunctionTypeReference.Argument)
        /// This value is a function
        case function(FunctionInstruction)
        /// This value is built in the language
        case builtin
        /// This value is the accessor function for a defined record's field
        case recordFieldAccessor(RecordType, RecordInstruction, BindInstruction)
        /// This value is the constructor function for a defined record
        case recordConstructor(RecordType, RecordInstruction)
        /// This value is the accessor function for a defined record's field
        case enumCase(EnumType, EnumInstruction, BindInstruction)
    }
}
