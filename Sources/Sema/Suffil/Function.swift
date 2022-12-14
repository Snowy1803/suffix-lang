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

public final class Function {
    public var parent: Function?
    public var name: String
    public var type: FunctionType
    public var source: Source
    var traits: TraitContainer
    
    var captures: [Capture]
    
    // these are empty if builtin or synthesized
    var arguments: [LocalRef]
    var instructions: [Inst]
    var notBuilt: Bool
    
    init(parent: Function?, name: String, type: FunctionType, source: Source, traits: TraitContainer) {
        assert(traits.type == .func)
        self.parent = parent
        self.name = name
        self.type = type
        self.source = source
        self.traits = traits
        self.captures = []
        self.arguments = [] // this is populated by the resolver
        self.instructions = []
        if case .instruction = source {
            notBuilt = true
        } else {
            notBuilt = false
        }
    }
    
    var isSynthesized: Bool {
        if case .synthesized = source {
            return true
        }
        return false
    }
    
    public enum Source {
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
        /// The location of the first time it was captured
        var firstLocation: LocationInfo
    }
}

extension Function: CustomStringConvertible {
    public var description: String {
        let sig = "suffil .\(name)\(type.generics.isEmpty ? "" : " [\(type.generics.map(\.description).joined(separator: ", "))]")"
        let captures = captures.map(\.ref.description).joined(separator: ", ")
        let arguments = (isSynthesized ? type.arguments : arguments as [CustomStringConvertible]).map(\.description).joined(separator: ", ")
        let returning = type.returning.map(\.description).joined(separator: ", ")
        let traits = traits.traits.keys.map(\.wrapped.name).sorted().map { ", " + $0 }.joined()
        let sign = "\(sig) (\(captures)) (\(arguments)) (\(returning))\(traits)"
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

extension Function: Equatable, Hashable {
    public static func ==(_ lhs: Function, _ rhs: Function) -> Bool {
        lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
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
                ref.value.assignNumber(with: &numberer)
            }
        }
    }
}
