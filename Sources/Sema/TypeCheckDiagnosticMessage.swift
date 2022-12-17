//
//  TypeCheckDiagnosticMessage.swift
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

extension Diagnostic {
    init(token: Token, message: TypeCheckDiagnosticMessage, severity: Severity, hints: [Diagnostic] = []) {
        self.init(token: token, message: message as DiagnosticMessage, severity: severity, hints: hints)
    }
    
    init(tokens: [Token], message: TypeCheckDiagnosticMessage, severity: Severity, hints: [Diagnostic] = []) {
        self.init(tokens: tokens, message: message as DiagnosticMessage, severity: severity, hints: hints)
    }
}

enum TypeCheckDiagnosticMessage: DiagnosticMessage {
    case negativeArgumentCount(IntegerValue)
    case unknownType(String)
    case unknownTrait(String)
    case missingTypeAnnotation
    case invalidTypeAnnotation
    case poppingEmptyStack
    case invalidStringEscapeSequence(Substring)
    case noViableBinding(String)
    case callNonCallable(String, SType)
    case returningTooMuch(expected: [SType], actual: [SType])
    case returnMissing(expected: [SType], actual: [SType])
    case returningFromMain
    case genericTypeParameterCountInvalid(expected: Int, actual: Int)
    case genericTypeParameterMissing(expected: Int)
    case captureInNoCaptureFunc(binding: String, function: String)
    case incompatibleTraitsProvided(TraitContainer.TraitInfo, TraitContainer.TraitInfo)
    case invalidTrait(expected: TraitContainerType, trait: TraitContainer.TraitInfo)
    
    case hintReturnHere(SType)
    case hintCaptureHere(String)
    case hintTraitExplicitHere(String)
    case hintTraitImpliedFrom(String, original: String)
    case hintTraitInheritedFrom(String)
    case hintUseFunctionWithCapturesBeforeDefinition(String)
    
    var description: String {
        switch self {
        case .negativeArgumentCount(let token):
            return "Invalid argument multiplier: \(token.integer) is negative"
        case .unknownType(let name):
            return "Could not find type '\(name)' in scope"
        case .unknownTrait(let name):
            return "Could not find trait '\(name)' in scope"
        case .missingTypeAnnotation:
            return "Missing type annotation"
        case .invalidTypeAnnotation:
            return "Unexpected type annotation"
        case .poppingEmptyStack:
            return "Cannot pop more values than there is on the stack"
        case .invalidStringEscapeSequence(let str):
            return "Unknown escape sequence '\(str)' in string"
        case .noViableBinding(let str):
            return "Could not find a viable binding named '\(str)'"
        case .callNonCallable(let str, let type):
            return "Cannot call value '\(str)' of non-function type '\(type)'"
        case .returningTooMuch(expected: let expected, actual: let actual):
            return "Returning too many values: expected to get (\(expected.map(\.description).joined(separator: ", "))) but found  (\(actual.map(\.description).joined(separator: ", ")))"
        case .returnMissing(expected: let expected, actual: let actual):
            return "Missing return values: expected to get (\(expected.map(\.description).joined(separator: ", "))) but found  (\(actual.map(\.description).joined(separator: ", ")))"
        case .returningFromMain:
            return "Unused value in main function"
        case .genericTypeParameterCountInvalid(expected: let expected, actual: let actual):
            return "Expected \(expected) type parameter\(expected > 1 ? "s" : ""), but found \(actual)"
        case .genericTypeParameterMissing(let expected):
            return "Generic type must be parameterized, expected \(expected) type parameter\(expected > 1 ? "s" : "")"
        case .captureInNoCaptureFunc(let name, let funcname):
            return "Cannot capture outside non-constant binding '\(name)', function '\(funcname)' has trait 'no capture'"
        case .incompatibleTraitsProvided(let lhs, let rhs):
            return "Traits '\(lhs.trait.wrapped.name)' and '\(rhs.trait.wrapped.name)' are incompatible"
        case .invalidTrait(expected: let expected, trait: let trait):
            return "Trait '\(trait.trait.wrapped.name)' cannot be used in a '\(expected)'"
        case .hintReturnHere(let type):
            return "Value of type '\(type)' returned here"
        case .hintCaptureHere(let name):
            return "Binding '\(name)' captured here"
        case .hintTraitExplicitHere(let name):
            return "Trait '\(name)' was added here"
        case .hintTraitImpliedFrom(let name, let original):
            return "Trait '\(name)' is implied by '\(original)'"
        case .hintTraitInheritedFrom(let name):
            return "Trait '\(name)' was inherited from an outer function"
        case .hintUseFunctionWithCapturesBeforeDefinition(let function):
            return "Using function '\(function)' before it is defined implies it does not capture values"
        }
    }
}

extension TraitContainer.TraitInfo {
    var hint: Diagnostic? {
        switch source {
        case .builtin:
            print("There should be no issue")
            return nil
        case .explicit(let traitReference):
            return Diagnostic(tokens: traitReference.nodeAllTokens, message: .hintTraitExplicitHere(self.trait.wrapped.name), severity: .hint)
        case .implied(let traitInfo):
            guard let og = traitInfo.hint else {
                return nil
            }
            return Diagnostic(tokens: og.tokens, message: .hintTraitImpliedFrom(self.trait.wrapped.name, original: traitInfo.trait.wrapped.name), severity: .hint)
        case .inherited(let traitInfo):
            guard let og = traitInfo.hint else {
                return nil
            }
            return Diagnostic(tokens: og.tokens, message: .hintTraitInheritedFrom(self.trait.wrapped.name), severity: .hint)
        case .implicitlyConstrained(let node, let reason):
            switch reason {
            case .functionUsedBeforeDefinition:
                return Diagnostic(tokens: node.nodeAllTokens, message: .hintUseFunctionWithCapturesBeforeDefinition(self.trait.wrapped.name), severity: .hint)
            }
        case .inferred:
            print("Inferences will only be added if there is no issue")
            return nil
        }
    }
}
