//
//  SType.swift
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

public enum SType {
    case primitive(PrimitiveType)
    case record(RecordType)
    case function(FunctionType)
}

public enum PrimitiveType: String {
    case int
    case bool
    case float
    case str
    case `func`
    case any
}

public struct FunctionType {
    public var arguments: [ArgumentSpec]
    public var returning: [ArgumentSpec]
    
    public struct ArgumentSpec {
        public var count: Count
        public var type: SType
        
        public enum Count {
            case infinite
            case exact(Int)
        }
    }
}

public struct RecordType {
    public var name: String
    public var fields: [Field]
    
    public struct Field {
        public var name: String
        public var type: SType
    }
}
