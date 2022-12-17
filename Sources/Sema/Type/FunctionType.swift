//
//  FunctionType.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 05/11/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

public class FunctionType: SType {
    let generics: [GenericArchetype]
    public let arguments: [Argument]
    public let returning: [Argument]
    let traits: TraitContainer
    
    init(generics: [GenericArchetype] = [], arguments: [Argument], returning: [Argument], traits: TraitContainer) {
        self.generics = generics
        self.arguments = arguments
        self.returning = returning
        self.traits = traits
    }
    
    var variadicIndex: Int? {
        arguments.firstIndex(where: \.variadic)
    }
    
    var isConcrete: Bool {
        variadicIndex == nil && generics.isEmpty
    }
    
    // (str, any) (int) is convertible to (str, bool) (any)
    // (str, any..., int) (int) is convertible to (str, bool, int, float, int) (any)
    // () () [pure] is convertible to () () [] but not the opposite
    public func convertible(to other: SType) -> Bool {
        guard let other = other as? FunctionType,
              other.returning.count == self.returning.count,
              zip(self.returning, other.returning).allSatisfy({ mine, others in
                  mine.type.canBeAssigned(to: others.type)
              }),
              other.traits.traits.keys.allSatisfy({ self.traits.traits.keys.contains($0) }) else {
            return false
        }
        func convertibleArgument(mine: Argument, others: Argument) -> Bool {
            others.type.canBeAssigned(to: mine.type)
        }
        switch (self.variadicIndex, other.variadicIndex) {
        case (nil, nil):
            return self.arguments.count == other.arguments.count && zip(self.arguments, other.arguments).allSatisfy(convertibleArgument)
        case (let myIndex?, let othersIndex?):
            return myIndex == othersIndex && self.arguments.count == other.arguments.count && zip(self.arguments, other.arguments).allSatisfy(convertibleArgument)
        case (nil, _?):
            return false // cannot convert non-variadic to variadic
        case (let variadicIndex?, nil):
            let packCount = other.arguments.count - (self.arguments.count - 1)
            if packCount < 0 {
                return false
            }
            return zip(self.arguments[0..<variadicIndex], other.arguments[0..<variadicIndex]).allSatisfy(convertibleArgument) && other.arguments[variadicIndex..<(variadicIndex + packCount)].allSatisfy {
                $0.type.canBeAssigned(to: self.arguments[variadicIndex].type)
            } && zip(self.arguments[(variadicIndex + 1)...], other.arguments[(variadicIndex + packCount + 1)...]).allSatisfy(convertibleArgument)
        }
    }
    
    public func map(with map: GenericMap) -> SType {
        FunctionType(
            generics: generics.filter { !map.contains(type: $0) },
            arguments: arguments.map { Argument(type: $0.type.map(with: map), variadic: $0.variadic) },
            returning: returning.map { Argument(type: $0.type.map(with: map), variadic: $0.variadic) },
            traits: traits
        )
    }
    
    public var description: String {
        var desc = ""
        if !generics.isEmpty {
            desc += "[\(generics.map(\.description).joined(separator: ", "))] "
        }
        desc += "(\(arguments.map(\.description).joined(separator: ", "))) "
        desc += "(\(returning.map(\.description).joined(separator: ", ")))"
        if !traits.traits.isEmpty {
            desc += " [\(traits.traits.keys.map(\.wrapped.name).sorted().joined(separator: ", "))]"
        }
        return desc
    }
    
    // ???: Currently unused
    public var genericArchetypesInDefinition: [GenericArchetype] { generics }
    
    public struct Argument: CustomStringConvertible {
        public var type: SType
        public var variadic: Bool = false
        
        public var description: String {
            "1: \(type)\(variadic ? "..." : "")"
        }
    }
}
