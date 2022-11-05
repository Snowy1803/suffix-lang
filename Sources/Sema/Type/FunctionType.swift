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
    public var arguments: [Argument]
    public var returning: [Argument]
    
    init(arguments: [Argument], returning: [Argument]) {
        self.arguments = arguments
        self.returning = returning
    }
    
    var variadicIndex: Int? {
        arguments.firstIndex(where: \.variadic)
    }
    
    // (str, any) (int) is convertible to (str, bool) (any)
    // (str, any..., int) (int) is convertible to (str, bool, int, float, int) (any)
    public func convertible(to other: SType) -> Bool {
        guard let other = other as? FunctionType,
              other.returning.count == self.returning.count,
              zip(self.returning, other.returning).allSatisfy({ mine, others in
                  mine.type.convertible(to: others.type)
              }) else {
            return false
        }
        func convertibleArgument(mine: Argument, others: Argument) -> Bool {
            others.type.convertible(to: mine.type)
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
                $0.type.convertible(to: self.arguments[variadicIndex].type)
            } && zip(self.arguments[(variadicIndex + 1)...], other.arguments[(variadicIndex + packCount + 1)...]).allSatisfy(convertibleArgument)
        }
    }
    
    public struct Argument {
        public var type: SType
        public var variadic: Bool = false
    }
}
