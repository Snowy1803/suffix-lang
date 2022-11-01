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
        self.literal = stream.consumeOne(
            assert: .identifier,
            recoveryDefault: "missing " + UUID().uuidString)
        self.typeAnnotation = TypeAnnotation(stream: stream)
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
            self.type = .generic(.init(name: Token(position: .missing, literal: "any", type: .identifier)))
        }
    }
}
