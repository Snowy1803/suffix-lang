//
//  Value+Build.swift
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

extension Value {
    func buildValue(context: FunctionParsingContext) -> (Ref, SType) {
        switch self {
        case .int(let integer):
            return (.intLiteral(integer.integer), IntType.shared)
        case .float(let float):
            return (.floatLiteral(float.float), FloatType.shared)
        case .string(let str):
            let elements = context.pop(count: str.components.map(\.popCount).reduce(0, +), source: [str.token])
            if elements.isEmpty {
                return (.strLiteral(str.components.map { $0.resolveStatic(token: str.token, context: context) }.joined()), StringType.shared)
            }
            var element = elements.makeIterator()
            let interpolation = str.components.flatMap { (component) -> [Ref] in
                switch component {
                case .literal, .escaped:
                    return [.strLiteral("s"), .strLiteral(component.resolveStatic(token: str.token, context: context))]
                case .percent(let substring):
                    return [.strLiteral("\(substring.dropFirst())"), element.next()?.ref ?? .strLiteral("")]
                }
            }
            // TODO: define that function
            let ftype = FunctionType(arguments: [.init(type: ArrayType(element: AnyType.shared))], returning: [.init(type: StringType.shared)])
            guard let ref = context.getBindings(name: "interpolate string literal").last(where: { $0.type.canBeAssigned(to: ftype) })?.ref else {
                context.typeChecker.diagnostics.append(Diagnostic(token: str.token, message: .noViableBinding("interpolate string literal"), severity: .error))
                return (.strLiteral(""), StringType.shared)
            }
            return (context.builder.buildCall(value: ref, type: ftype, parameters: [context.builder.buildArray(elementType: AnyType.shared, elements: interpolation)])[0], StringType.shared)
        case .reference(let ref):
            return ref.buildValue(context: context)
        case .anonymousFunc(let fn):
            let subcontext = fn.createAnonymousFunctionContext(parent: context)
            fn.registerLocalBindings(subcontext: subcontext)
            fn.block.content.typecheckContent(context: subcontext)
            let closure = context.builder.buildClosure(function: subcontext.function)
            return (closure, subcontext.function.type)
        }
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
        case .percent:
            fatalError()
        }
    }
}
