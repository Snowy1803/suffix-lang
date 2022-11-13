//
//  ReferenceValue+Parse.swift
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

extension ReferenceValue {
    init(stream: TokenStream) {
        self.identifier = TypedIdentifier(stream: stream)
        if identifier.typeAnnotation == nil { // can't have both
            self.generics = GenericTypeArguments(stream: stream)
            self.argumentCount = TakenArgumentCount(stream: stream)
        }
    }
}

extension TypedIdentifier {
    init(stream: TokenStream) {
        self.literal = Identifier(assert: stream, allow: .inBinding)
        self.typeAnnotation = TypeAnnotation(stream: stream)
    }
}

extension TakenArgumentCount {
    init?(stream: TokenStream) {
        guard let open = stream.consumeOne(type: .parenOpen) else {
            return nil
        }
        self.open = open
        self.count = IntegerValue(stream: stream) ?? {
            stream.diagnostics.append(Diagnostic(token: stream.nextTokenForDiagnostics(), message: ParserDiagnosticMessage.expectedTokenType(.number), severity: .error))
            return IntegerValue(tokens: [Token(position: .missing, literal: "0", type: .number)], integer: 0)
        }()
        self.close = stream.consumeOne(assert: .parenClose, recoveryDefault: ")")
    }
}

extension TypeAnnotation {
    init?(stream: TokenStream) {
        guard let colon = stream.consumeOne(type: .typingOperator) else {
            return nil
        }
        self.colon = colon
        if let ref = TypeReference(stream: stream) {
            self.type = ref
        } else {
            stream.diagnostics.append(Diagnostic(token: colon, message: ParserDiagnosticMessage.expectedNode(TypeReference.self), severity: .error))
            self.type = .generic(.init(name: Identifier(tokens: [Token(position: .missing, literal: "any", type: .word)], identifier: "any")))
        }
    }
}
