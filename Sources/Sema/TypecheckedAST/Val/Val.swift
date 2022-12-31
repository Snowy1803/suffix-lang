//
//  Val.swift
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
import SuffixLang

public enum Val {
    case int(IntVal)
    case float(FloatValue)
    case stringLiteral(ConstantStringVal)
    case stringInterpolation(StringInterpolationVal)
    case reference(ReferenceVal)
    case anonymousFunc(AnonymousFunctionVal)
    case callReturn(CallReturnVal)
    case argument(ArgumentVal)
}

extension Val {
    var type: SType {
        switch self {
        case .int(let intVal):
            return intVal.type
        case .float:
            return FloatType.shared
        case .stringLiteral(let str):
            return str.type
        case .stringInterpolation(let str):
            return str.type
        case .reference(let referenceVal):
            return referenceVal.type
        case .anonymousFunc(let anonymousFunctionVal):
            return anonymousFunctionVal.type
        case .callReturn(let callReturnVal):
            return callReturnVal.type
        case .argument(let argumentVal):
            return argumentVal.type
        }
    }
    
//    var node: ASTNode? {
//        switch self {
//        case .int(let intVal):
//            switch intVal.source {
//            case .ast(let node): return node
//            case .builtin: return nil
//            }
//        case .float(let node as ASTNode),
//             .string(let node as ASTNode):
//            return node
//        case .reference(let referenceVal):
//            switch referenceVal.source {
//            case .ast(let node): return node
//            }
//        case .anonymousFunc(let anonymousFunctionVal):
//            return anonymousFunctionVal.source
//        case .callReturn(let callReturnVal):
//            return callReturnVal.call.source
//        case .argument(let argumentVal):
//            return argumentVal.source
//        }
//    }
}

extension Val: CustomStringConvertible {
    public var description: String {
        switch self {
        case .int(let intVal):
            return intVal.description
        case .float(let float):
            return "\(float.float)"
        case .stringLiteral(let str):
            return str.description
        case .stringInterpolation(let str):
            return str.description
        case .reference(let referenceVal):
            return referenceVal.description
        case .anonymousFunc(let anonymousFunctionVal):
            return anonymousFunctionVal.description
        case .callReturn(let callReturnVal):
            return callReturnVal.description
        case .argument(let argumentVal):
            return argumentVal.description
        }
    }
}
