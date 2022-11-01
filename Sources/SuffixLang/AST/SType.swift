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

enum SType {
    case primitive(PrimitiveType)
    case record(RecordType)
    case function(FunctionType)
}

enum PrimitiveType: String {
    case int
    case bool
    case float
    case str
    case `func`
    case any
}

struct FunctionType {
    var arguments: [ArgumentSpec]
    var returning: [ArgumentSpec]
    
    struct ArgumentSpec {
        var count: Count
        var type: SType
        
        enum Count {
            case infinite
            case exact(Int)
        }
    }
}

struct RecordType {
    var name: String
    var fields: [Field]
    
    struct Field {
        var name: String
        var type: SType
    }
}
