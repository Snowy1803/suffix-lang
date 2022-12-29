//
//  Instruction+Check.swift
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

extension Instruction {
    func registerTypeDeclaration(context: FunctionParsingContext) -> InstructionAfterTypeDeclaration {
        switch self {
        case .push(let pushInstruction):
            return .push(pushInstruction)
        case .call(let callInstruction):
            return .call(callInstruction)
        case .bind(let bindInstruction):
            return .bind(bindInstruction)
        case .function(let functionInstruction):
            return .function(functionInstruction)
        case .record(let recordInstruction):
            return .record(recordInstruction.registerTypeDeclaration(context: context))
        case .enum(let enumInstruction):
            return .enum(enumInstruction.registerTypeDeclaration(context: context))
        }
    }
}

extension InstructionAfterTypeDeclaration {
    func registerGlobalBindings(context: FunctionParsingContext) -> InstructionAfterRegisteringGlobalBindings {
        switch self {
        case .push(let pushInstruction):
            return .push(pushInstruction)
        case .call(let callInstruction):
            return .call(callInstruction)
        case .bind(let bindInstruction):
            return .bind(bindInstruction)
        case .function(let functionInstruction):
            let stmt = functionInstruction.buildInstruction(context: context)
            let function = stmt.registerGlobalBindings(parent: context)
            return .function(stmt, function)
        case .record(let recordType):
            recordType.registerGlobalBindings(context: context)
            return .record(recordType)
        case .enum(let enumType):
            enumType.registerGlobalBindings(context: context)
            return .enum(enumType)
        }
    }
}

extension InstructionAfterRegisteringGlobalBindings {
    func buildInstruction(context: FunctionParsingContext) -> Stmt {
        switch self {
        case .push(let pushInstruction):
            return .push(pushInstruction.buildInstruction(context: context))
        case .call(let callInstruction):
            return .call(callInstruction.buildInstruction(context: context))
        case .bind(let bindInstruction):
            return .bind(bindInstruction.buildInstruction(context: context))
        case .function(let functionStmt, let function):
            let subcontext = functionStmt.createSubContext(parent: context, function: function)
            functionStmt.source.arguments.registerLocalBindings(subcontext: subcontext)
            switch functionStmt.source.block {
            case .block(let block):
                if let info = subcontext.function.traits.traits[.function(.extern)] {
                    context.typeChecker.diagnostics.append(Diagnostic(token: block.open, message: .externWithBlock, severity: .error, hints: [info.hint].compactMap({ $0 })))
                }
                functionStmt.content = block.content.typecheckContent(context: subcontext)
            case .semicolon(let token):
                if subcontext.function.traits.traits[.function(.extern)] == nil {
                    subcontext.function.traits.add(trait: TraitContainer.TraitInfo(trait: .function(.extern), source: .implicitlyConstrained(token, reason: .functionWithSemicolon)), diagnostics: &context.typeChecker.diagnostics)
                }
            }
            return .function(functionStmt)
        case .record(let recordType):
            return .record(recordType)
        case .enum(let enumType):
            return .enum(enumType)
        }
    }
}

enum InstructionAfterTypeDeclaration {
    case push(PushInstruction)
    case call(CallInstruction)
    case bind(BindInstruction)
    case function(FunctionInstruction)
    case record(RecordType)
    case `enum`(EnumType)
}

enum InstructionAfterRegisteringGlobalBindings {
    case push(PushInstruction)
    case call(CallInstruction)
    case bind(BindInstruction)
    case function(FunctionStmt, TFunction)
    case record(RecordType)
    case `enum`(EnumType)
}
