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
    var function: Function
    var stack: [StackElement] = []
    var builder: SuffilBuilder
    
    var registeredFunctions: [ObjectID<FunctionInstruction>: Function] = [:]
    
    init(parent: ParsingContext, function: Function) {
        self.function = function
        self.builder = SuffilBuilder(function: function)
        super.init(parent: parent)
    }
    
    func createFunction(name: String, type: FunctionType, source: Function.Source) -> Function {
        let fn = Function(parent: self.function, name: name, type: type, source: source)
        typeChecker.functions.append(fn)
        return fn
    }
    
    func pop(count: Int, source: @autoclosure () -> [Token]) -> [StackElement] {
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
    
    override func capture(binding: Binding, node: ASTNode) -> Ref! {
        if binding.ref.isConstant {
            return binding.ref
        }
        if bindings.contains(where: { $0 === binding }) {
            if case .function(let fn) = binding.ref,
               case .instruction = fn.source {
                binding.ref = builder.buildClosure(function: LocatedFunction(value: fn, node: node, binding: binding))
            }
            return binding.ref
        }
        if let match = function.captures.first(where: { $0.binding === binding }) {
            return .local(match.ref)
        }
        guard let toCapture = parent?.capture(binding: binding, node: node) else {
            return nil
        }
        let capture = LocalRef(givenName: binding.name, type: binding.type)
        function.captures.append(Function.Capture(binding: binding, ref: capture, parentRef: toCapture, firstLocation: LocationInfo(value: (), node: node, binding: binding)))
        return .local(capture)
    }
}
