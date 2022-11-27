//
//  Function.swift
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

public class Function {
    var parent: Function?
    var name: String
    var type: FunctionType
    var source: Source
    
    var captures: [Capture]
    
    // these are empty if builtin or synthesized
    var arguments: [LocalRef]
    var instructions: [Inst]
    
    init(parent: Function?, name: String, type: FunctionType, source: Source) {
        self.parent = parent
        self.name = name
        self.type = type
        self.source = source
        self.captures = []
        self.arguments = [] // this is populated by the resolver
        self.instructions = []
    }
    
    var isSynthesized: Bool {
        if case .synthesized = source {
            return true
        }
        return false
    }
    
    enum Source {
        case instruction(FunctionInstruction)
        case anonymous(AnonymousFunctionValue)
        case main
        case builtin
        case synthesized
    }
    
    struct Capture {
        /// The original binding for the capture
        var binding: Binding
        /// The created value
        var ref: LocalRef
        /// The ref it refers to in the parent's context
        var parentRef: Ref
    }
}

extension Function: CustomStringConvertible {
    public var description: String {
        let sig = "suffil .\(name)\(type.generics.isEmpty ? "" : " [\(type.generics.map(\.description).joined(separator: ", "))]")"
        let captures = captures.map(\.ref.description).joined(separator: ", ")
        let arguments = (isSynthesized ? type.arguments : arguments as [CustomStringConvertible]).map(\.description).joined(separator: ", ")
        let returning = type.returning.map(\.description).joined(separator: ", ")
        let sign = "\(sig) (\(captures)) (\(arguments)) (\(returning))"
        if isSynthesized {
            return "\(sign)\n"
        } else {
            var desc = "\(sign) {\n"
            for inst in instructions {
                desc += "    " + inst.wrapped.description + "\n"
            }
            desc += "}\n"
            return desc
        }
    }
}

extension Function {
    func prepareSuffilForPrinting() {
        var numberer = LocalRefNumberer()
        for capture in captures {
            capture.ref.assignNumber(with: &numberer)
        }
        for argument in arguments {
            argument.assignNumber(with: &numberer)
        }
        for instruction in instructions {
            for ref in instruction.wrapped.definingRefs {
                ref.assignNumber(with: &numberer)
            }
        }
    }
}
