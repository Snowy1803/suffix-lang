//
//  CallInstruction+Build.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 19/11/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

extension CallInstruction {
    func buildInstruction(context: FunctionParsingContext) -> CallStmt {
        let value = value.buildValue(context: context)
        context.constrainFunctionType(type: value.type)
//        assert(type.isConcrete) // TODO: make it non-variadic in ReferenceValue.buildValue
        let possibilities = context.computePossibleBindings(reference: value)
        var argumentCount: Int?
        var returnCount: Int?
        for possibility in possibilities {
            if let type = possibility.type as? FunctionType {
                if type.variadicIndex != nil { // variadic function
                    argumentCount = nil
                    break
                } else if argumentCount == nil {
                    argumentCount = type.arguments.count
                } else if argumentCount == type.arguments.count {
                    // yay
                } else { // different ones
                    argumentCount = nil
                    break
                }
                if returnCount == nil {
                    returnCount = type.returning.count
                } else if returnCount == type.returning.count {
                    // yay
                } else { // different ones
                    returnCount = nil
                    break
                }
            } else {
                // ignore unresolved type
            }
        }
        let actualArgCount: Int
        if let argumentCount {
            actualArgCount = argumentCount
        } else {
            context.typeChecker.diagnostics.append(Diagnostic(tokens: self.value.identifier.literal.tokens, message: .argumentCountMissing(value.name), severity: .error))
            actualArgCount = 0
        }
        let actualReturnCount: Int
        if let returnCount {
            actualReturnCount = returnCount
        } else {
            context.typeChecker.diagnostics.append(Diagnostic(tokens: self.value.identifier.literal.tokens, message: .ambiguousReturnCount(value.name), severity: .error))
            actualReturnCount = 0
        }
        let parameters = context.pop(count: actualArgCount, source: nodeAllTokens)
        let argumentTypes = (0..<actualArgCount).map { i -> SType in
            if i < parameters.count {
                return parameters[i].value.type
            } else {
                return context.createUnresolvedType()
            }
        }
        let returnTypes = (0..<actualReturnCount).map { _ in context.createUnresolvedType() }
        let functionType = FunctionType(
            arguments: argumentTypes.map { .init(type: $0) },
            returning: returnTypes.map { .init(type: $0) },
            // TODO: add 'pure' trait if we're in a pure func
            traits: TraitContainer(type: .func, source: false, traits: [], diagnostics: &context.typeChecker.diagnostics))
        let stmt = CallStmt(input: parameters, function: value, functionType: functionType, source: self)
        // TODO: resolve generics / specialise and stuff
        for (i, returnType) in returnTypes.enumerated() {
            let elem = TStackElement(value: .callReturn(CallReturnVal(call: stmt, index: i, type: returnType)))
            context.stack.append(elem)
        }
        return stmt
    }
}
