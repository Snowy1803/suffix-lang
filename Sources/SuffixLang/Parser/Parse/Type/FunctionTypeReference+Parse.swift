//
//  FunctionTypeReference+Parse.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 23/10/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension FunctionTypeReference {
    init?(stream: TokenStream) {
        guard let arguments = Arguments(stream: stream) else {
            return nil
        }
        self.arguments = arguments
        self.returning = Arguments(assert: stream)
    }
}

extension FunctionTypeReference.Arguments {
    static let recovery = FunctionTypeReference.Arguments(
        open: Token(position: .missing, literal: "(", type: .parenOpen),
        arguments: [],
        close: Token(position: .missing, literal: ")", type: .parenClose))
    
    init?(stream: TokenStream) {
        guard let open = stream.consumeOne(type: .parenOpen) else {
            return nil
        }
        self.open = open
        self.arguments = []
        while let generic = FunctionTypeReference.Argument(stream: stream) {
            self.arguments.append(generic)
        }
        self.close = stream.consumeOne(assert: .parenClose, recoveryDefault: ")")
    }
    
    init(assert stream: TokenStream) {
        if let args = Self(stream: stream) {
            self = args
        } else {
            self = .recovery
            stream.diagnostics.append(Diagnostic(token: stream.peekNext() ?? .onePastEnd(document: stream.document), message: ParserDiagnosticMessage.expectedNode(Self.self), severity: .error))
        }
    }
}

extension FunctionTypeReference.Argument {
    init?(stream: TokenStream) {
        guard let spec = Spec(stream: stream) else {
            return nil
        }
        self.spec = spec
        self.typeAnnotation = TypeAnnotation(stream: stream)
        if let comma = stream.consumeOne(type: .comma) {
            self.trailingComma = comma
        }
    }
}

extension FunctionTypeReference.Argument.Spec {
    init?(stream: TokenStream) {
        if let int = IntegerValue(stream: stream) {
            self = .count(int)
        } else if let spec = Variadic(stream: stream) {
            self = .unnamedVariadic(spec)
        } else if let spec = Named(stream: stream) {
            self = .named(spec)
        } else {
            return nil
        }
    }
}

extension FunctionTypeReference.Argument.Spec.Variadic {
    init?(stream: TokenStream) {
        guard let token = stream.consumeOne(type: .variadic) else {
            return nil
        }
        self.token = token
    }
}

extension FunctionTypeReference.Argument.Spec.Named {
    init?(stream: TokenStream) {
        guard let token = stream.consumeOne(type: .identifier) else {
            return nil
        }
        self.name = token
        self.variadic = .init(stream: stream)
    }
}
