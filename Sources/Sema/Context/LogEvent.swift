//
//  LogEvent.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 18/12/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

public enum LogEvent {
    /// A binding was created, with a global scope, which means it is visible inside the full scope of the function
    case globalBindingCreated(Binding, Function)
    /// A binding was created, with a local scope, which means it is visible starting at the source location
    case localBindingCreated(Binding, Function)
    /// A function was declared
    case funcCreated(Function)
    /// An enum was declared
    case enumCreated(EnumType)
    /// A record was declared
    case recordCreated(RecordType)
    
    /// A binding was referenced
    case bindingReferenced(Binding, ReferenceValue)
    /// A named type was referenced
    case namedTypeReferenced(NamedType, GenericTypeReference)
    /// A function type was referenced
    case functionTypeReferenced(FunctionType, FunctionTypeReference)
}
