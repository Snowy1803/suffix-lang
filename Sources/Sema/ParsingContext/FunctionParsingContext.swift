//
//  FunctionParsingContext.swift
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

class FunctionParsingContext: ParsingContext {
    var function: TFunction
    var stack: [TStackElement] = []
    
    var constraints = ConstraintContainer()
    
    init(parent: ParsingContext, function: TFunction) {
        self.function = function
        super.init(parent: parent)
    }
    
    func createFunction(name: String, type: SType, content: TFunction.Content, traits: TraitContainer) -> TFunction {
        let fn = TFunction(parent: self.function, name: name, type: type, content: content, traits: traits)
//        typeChecker.functions.append(fn)
//        typeChecker.logger.log(.funcCreated(fn))
        return fn
    }
    
    override func add(global: Bool, binding: TBinding) {
        super.add(global: global, binding: binding)
//        if global {
//            typeChecker.logger.log(.globalBindingCreated(binding, function))
//        } else {
//            typeChecker.logger.log(.localBindingCreated(binding, function))
//        }
    }
    
    func pop(count: Int, source: @autoclosure () -> [Token]) -> [TStackElement] {
        let result = Array(stack.suffix(count))
        if result.count == count {
            stack.removeLast(count)
            return result
        } else {
            typeChecker.diagnostics.append(Diagnostic(tokens: source(), message: .poppingEmptyStack, severity: .error))
            stack.removeAll()
            return result
        }
    }
}
