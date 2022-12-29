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
    func typecheckContent(context: FunctionParsingContext) -> [Stmt] {
        var statements = instructions.map {
            $0.registerTypeDeclaration(context: context)
        }.map {
            $0.registerGlobalBindings(context: context)
        }.map {
            $0.buildInstruction(context: context)
        }
        statements.append(.ret(buildRet(context: context)))
        return statements
    }
    
    func buildRet(context: FunctionParsingContext) -> RetStmt {
        let expectedTypes = context.function.type.returning.map(\.type)
        let stack = context.stack
        if expectedTypes.count < stack.count {
            let token: Token
            switch context.function.content {
            case .statement(let fn):
                if case .block(let block) = fn.source.block {
                    token = block.close
                } else {
                    preconditionFailure("can't build ret for an extern function")
                }
            case .anonymous(let fn):
                token = fn.source.block.close
            case .main:
                for value in context.stack {
                    let tokens = value.source.node.nodeAllTokens
                    context.typeChecker.diagnostics.append(Diagnostic(tokens: tokens, message: .returningFromMain, severity: .error))
                }
                return RetStmt(input: [], parent: context.function)
            }
            context.typeChecker.diagnostics.append(Diagnostic(
                token: token,
                message: .returningTooMuch(expected: expectedTypes, actual: stack.map(\.value.type)),
                severity: .error,
                hints: context.stack.map { value in
                    let tokens = value.source.node.nodeAllTokens
                    return Diagnostic(tokens: tokens, message: .hintReturnHere(value.value.type), severity: .hint)
                }
            ))
        } else if expectedTypes.count > stack.count {
            let token: Token
            switch context.function.content {
            case .main:
                preconditionFailure("The stack count can't be less than 0")
            case .statement(let fn):
                if case .block(let block) = fn.source.block {
                    token = block.close
                } else {
                    preconditionFailure("can't build ret for an extern function")
                }
            case .anonymous(let fn):
                token = fn.source.block.close
            }
            context.typeChecker.diagnostics.append(Diagnostic(
                token: token,
                message: .returnMissing(expected: expectedTypes, actual: stack.map(\.value.type)),
                severity: .error,
                hints: context.stack.map { value in
                    let tokens = value.source.node.nodeAllTokens
                    return Diagnostic(tokens: tokens, message: .hintReturnHere(value.value.type), severity: .hint)
                }
            ))
        } else {
            // TODO: create constraints
        }
        return RetStmt(input: stack, parent: context.function)
    }
}
