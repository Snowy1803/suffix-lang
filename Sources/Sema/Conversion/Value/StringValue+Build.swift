//
//  File.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 31/12/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

extension StringValue {
    func buildValue(context: FunctionParsingContext) -> Val {
        let elements = context.pop(count: components.map(\.popCount).reduce(0, +), source: [token])
        if elements.isEmpty {
            let str = components.map { $0.resolveStatic(token: token, context: context) }.joined()
            return .stringLiteral(ConstantStringVal(value: str, type: StringType.shared, source: .ast(self)))
        }
        let ftype = FunctionType(arguments: [.init(type: ArrayType(element: AnyType.shared))], returning: [.init(type: StringType.shared)], traits: TraitContainer(type: .func, source: false, builtin: [.function(.constant)]))
        let ref = createStringInterpolationFunctionRef(name: "interpolate string literal", type: ftype, context: context)
        return .stringInterpolation(StringInterpolationVal(input: elements, components: components, interpolationFunction: ref, interpolationFunctionType: ftype, type: StringType.shared, source: .ast(self)))
    }
}

extension Token.StringComponent {
    /// Only valid on static string components (not .percent)
    func resolveStatic(token: Token, context: FunctionParsingContext) -> String {
        switch self {
        case .literal(let substring):
            return "\(substring.description)"
        case .escaped(let substring):
            let char = substring.suffix(1)
            switch char {
            case "\\", "\"", "%": return "\(char)"
            case "n": return "\n"
            case "r": return "\r"
            case "t": return "\t"
            case "b": return "\u{8}"
            case "e": return "\u{1b}"
            case "0": return "\u{0}"
            default:
                // TODO: place diagnostic more precisely
                context.typeChecker.diagnostics.append(Diagnostic(token: token, message: .invalidStringEscapeSequence(substring), severity: .error))
                return "\(char)"
            }
        case .percent(let substring):
            // Happens if there is 0 stack elements and a % is still used. a diagnostic is already issued
            return "\(substring.description)"
        }
    }
}
