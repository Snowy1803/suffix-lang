//
//  BlockContent+Check.swift
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

extension BlockContent {
    /// The type checker acts in multiple passes:
    /// - parse type declarations
    /// - parse global bindings (type fields and function signatures)
    /// - parse instructions and their content
    func typecheckContent(context: FunctionParsingContext) {
        instructions.forEach {
            $0.registerTypeDeclaration(context: context)
        }
        instructions.forEach {
            $0.registerGlobalBindings(context: context)
        }
        instructions.forEach {
            $0.buildInstruction(context: context)
        }
        context.bindings.forEach {
            context.builder.buildDestroy(value: LocatedRef(value: $0.ref, binding: $0))
        }
        buildRet(context: context)
    }
    
    func buildRet(context: FunctionParsingContext) {
        let expectedTypes = context.function.type.returning.map(\.type)
        let actualTypes = context.stack.map(\.type)
        if expectedTypes.count < actualTypes.count {
            let token: Token
            switch context.function.source {
            case .synthesized, .builtin:
                preconditionFailure()
            case .instruction(let fn):
                if case .block(let block) = fn.block {
                    token = block.close
                } else {
                    preconditionFailure()
                }
            case .anonymous(let fn):
                token = fn.block.close
            case .main:
                for value in context.stack {
                    let tokens: [Token]
                    switch value.source {
                    case .returnValue(let element as ASTNode), .argument(let element as ASTNode), .push(let element as ASTNode):
                        tokens = element.nodeAllTokens
                    }
                    context.typeChecker.diagnostics.append(Diagnostic(tokens: tokens, message: .returningFromMain, severity: .error))
                }
                return
            }
            context.typeChecker.diagnostics.append(Diagnostic(
                token: token,
                message: .returningTooMuch(expected: expectedTypes, actual: actualTypes),
                severity: .error,
                hints: context.stack.map { value in
                    let tokens: [Token]
                    switch value.source {
                    case .returnValue(let element as ASTNode), .argument(let element as ASTNode), .push(let element as ASTNode):
                        tokens = element.nodeAllTokens
                    }
                    return Diagnostic(tokens: tokens, message: .hintReturnHere(value.type), severity: .hint)
                }
            ))
        } else if expectedTypes.count > actualTypes.count {
            let token: Token
            switch context.function.source {
            case .synthesized, .builtin, .main:
                preconditionFailure()
            case .instruction(let fn):
                if case .block(let block) = fn.block {
                    token = block.close
                } else {
                    preconditionFailure()
                }
            case .anonymous(let fn):
                token = fn.block.close
            }
            context.typeChecker.diagnostics.append(Diagnostic(
                token: token,
                message: .returnMissing(expected: expectedTypes, actual: actualTypes),
                severity: .error,
                hints: context.stack.map { value in
                    let tokens: [Token]
                    switch value.source {
                    case .returnValue(let element as ASTNode), .argument(let element as ASTNode), .push(let element as ASTNode):
                        tokens = element.nodeAllTokens
                    }
                    return Diagnostic(tokens: tokens, message: .hintReturnHere(value.type), severity: .hint)
                }
            ))
        } else {
            // TODO: check types
            context.builder.buildRet(values: context.stack.map(\.ref).map(\.noLocation))
        }
    }
}
