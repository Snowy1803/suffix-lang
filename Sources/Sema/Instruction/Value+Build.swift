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
    func buildValue(context: FunctionParsingContext) -> (LocatedRef, SType) {
        switch self {
        case .int(let integer):
            return (LocatedRef(value: .intLiteral(integer.integer), node: integer), IntType.shared)
        case .float(let float):
            return (LocatedRef(value: .floatLiteral(float.float), node: float), FloatType.shared)
        case .string(let str):
            let elements = context.pop(count: str.components.map(\.popCount).reduce(0, +), source: [str.token])
            if elements.isEmpty {
                return (LocatedRef(value: .strLiteral(str.components.map { $0.resolveStatic(token: str.token, context: context) }.joined()), node: str), StringType.shared)
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
            let ftype = FunctionType(arguments: [.init(type: ArrayType(element: AnyType.shared))], returning: [.init(type: StringType.shared)], traits: TraitContainer(type: .func, source: false, builtin: [.function(.constant)]))
            guard let ref = context.getBindings(name: "interpolate string literal").last(where: { $0.type.canBeAssigned(to: ftype) })?.ref else {
                context.typeChecker.diagnostics.append(Diagnostic(token: str.token, message: .noViableBinding("interpolate string literal"), severity: .error))
                return (LocatedRef(value: .strLiteral(""), node: str), StringType.shared)
            }
            let interpolationArgs = context.builder.buildArray(elementType: AnyType.shared, elements: interpolation.map(\.noLocation))
            let interpolationCall = context.builder.buildCall(value: ref.noLocation, type: ftype, parameters: [interpolationArgs.noLocation])
            return (LocatedRef(value: interpolationCall[0], node: str), StringType.shared)
        case .reference(let ref):
            return ref.buildValue(context: context)
        case .anonymousFunc(let fn):
            let subcontext = fn.createAnonymousFunctionContext(parent: context)
            fn.registerLocalBindings(subcontext: subcontext)
            fn.block.content.typecheckContent(context: subcontext)
            let closure = context.builder.buildClosure(function: LocatedFunction(value: subcontext.function, node: fn))
            return (LocatedRef(value: closure, node: fn), subcontext.function.type)
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
