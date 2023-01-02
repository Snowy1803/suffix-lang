//
//  TFunction.swift
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

public final class TFunction: ReferenceHashable {
    public var parent: TFunction?
    public var name: String
    public var type: SType // GenericType / FunctionType
    public var content: Content
    public var traits: TraitContainer
    
    init(parent: TFunction?, name: String, type: SType, content: Content, traits: TraitContainer) {
        assert(type is FunctionType || (type is GenericType && (type as! GenericType).wrapped is FunctionType))
        assert(traits.type == .func)
        self.parent = parent
        self.name = name
        self.type = type
        self.content = content
        self.traits = traits
    }
    
    var generics: [GenericArchetype] {
        switch type {
        case let type as GenericType:
            return type.generics
        case is FunctionType:
            return []
        default:
            preconditionFailure()
        }
    }
    
    var functionType: FunctionType {
        switch type {
        case let type as GenericType:
            return type.wrapped as! FunctionType
        case let type as FunctionType:
            return type
        default:
            preconditionFailure()
        }
    }
    
    public enum Content {
        case statement(FunctionStmt)
        case anonymous(AnonymousFunctionVal)
        case main
    }
    
    var arguments: [ArgumentSpec] {
        _read {
            switch content {
            case .statement(let functionStmt):
                yield functionStmt.arguments
            case .anonymous(let anonymousFunctionVal):
                yield anonymousFunctionVal.arguments
            case .main:
                yield []
            }
        }
        _modify {
            switch content {
            case .statement(let functionStmt):
                yield &functionStmt.arguments
            case .anonymous(let anonymousFunctionVal):
                yield &anonymousFunctionVal.arguments
            case .main:
                fatalError()
            }
        }
    }
}

