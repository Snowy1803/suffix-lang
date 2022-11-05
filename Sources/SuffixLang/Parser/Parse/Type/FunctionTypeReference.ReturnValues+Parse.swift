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

extension FunctionTypeReference.ReturnValues {
    static let recovery = FunctionTypeReference.ReturnValues(
        open: Token(position: .missing, literal: "(", type: .parenOpen),
        arguments: [],
        close: Token(position: .missing, literal: ")", type: .parenClose))
    
    init?(stream: TokenStream) {
        guard let open = stream.consumeOne(type: .parenOpen) else {
            return nil
        }
        self.open = open
        self.arguments = []
        while let generic = FunctionTypeReference.ReturnValue(stream: stream) {
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

extension FunctionTypeReference.ReturnValue {
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

extension FunctionTypeReference.ReturnValue.Spec {
    init?(stream: TokenStream) {
        if let int = Count(stream: stream) {
            self = .count(int)
        } else if let type = TypeReference(stream: stream) {
            self = .single(type)
        } else {
            return nil
        }
    }
}

extension FunctionTypeReference.ReturnValue.Spec.Count {
    init?(stream: TokenStream) {
        guard let count = IntegerValue(stream: stream) else {
            return nil
        }
        self.count = count
        self.typeAnnotation = TypeAnnotation(stream: stream)
    }
}
