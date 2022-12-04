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
            stream.diagnostics.append(Diagnostic(token: stream.nextTokenForDiagnostics(), message: ParserDiagnosticMessage.expectedNode(Self.self), severity: .error))
        }
    }
}

extension FunctionTypeReference.Argument {
    init?(stream: TokenStream) {
        guard let spec = Spec(stream: stream) else {
            return nil
        }
        self.spec = spec
        if let comma = stream.consumeOne(type: .comma) {
            self.trailingComma = comma
        }
    }
}

extension FunctionTypeReference.Argument.Spec {
    init?(stream: TokenStream) {
        if let int = Count(stream: stream) {
            self = .count(int)
        } else if let spec = Variadic(stream: stream) {
            self = .unnamedVariadic(spec)
        } else if let spec = Named(stream: stream) {
            self = .named(spec)
        } else if let spec = TypeReference(stream: stream) {
            self = .unnamedSingle(spec)
        } else {
            return nil
        }
    }
}

extension FunctionTypeReference.Argument.Spec.Count {
    init?(stream: TokenStream) {
        let state = stream.saveState()
        guard let count = IntegerValue(stream: stream),
              let typeAnnotation = TypeAnnotation(stream: stream) else {
            stream.restore(state: state)
            return nil
        }
        self.count = count
        self.typeAnnotation = typeAnnotation
    }
}

extension FunctionTypeReference.Argument.Spec.Variadic {
    init?(stream: TokenStream) {
        let state = stream.saveState()
        guard let token = stream.consumeOne(type: .variadic),
              let typeAnnotation = TypeAnnotation(stream: stream) else {
            stream.restore(state: state)
            return nil
        }
        self.token = token
        self.typeAnnotation = typeAnnotation
    }
}

extension FunctionTypeReference.Argument.Spec.Named {
    init?(stream: TokenStream) {
        let state = stream.saveState()
        guard let token = Identifier(stream: stream, allow: .inBinding) else {
            return nil
        }
        self.name = token
        self.variadic = stream.consumeOne(type: .variadic)
        guard let typeAnnotation = TypeAnnotation(stream: stream) else {
            stream.restore(state: state)
            return nil
        }
        self.typeAnnotation = typeAnnotation
    }
}
