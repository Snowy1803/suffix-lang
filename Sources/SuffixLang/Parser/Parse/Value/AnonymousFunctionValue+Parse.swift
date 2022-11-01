//
//  AnonymousFunctionValue+Parse.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 31/10/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension AnonymousFunctionValue {
    init?(stream: TokenStream) {
        if stream.peekNext(type: .curlyOpen) {
            self.keyword = Token(position: .missing, literal: "func", type: .keyword)
            self.arguments = .recovery
            self.returning = .recovery
            self.block = Block(stream: stream)
        } else {
            guard let keyword = stream.consumeOne(if: { $0.type == .stringLiteral }) else {
                return nil
            }
            self.keyword = keyword
            self.arguments = FunctionTypeReference.Arguments(assert: stream)
            self.returning = FunctionTypeReference.Arguments(assert: stream)
            self.block = Block(stream: stream)
        }
    }
}
