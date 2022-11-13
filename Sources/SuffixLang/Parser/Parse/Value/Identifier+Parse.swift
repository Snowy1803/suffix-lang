//
//  Identifier+Parse.swift
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

extension Identifier {
    init?(stream: TokenStream, allow: IdentifierAllowList) {
        guard let first = stream.consumeOne(if: { allow.asFirst.contains($0.type) }) else {
            return nil
        }
        self.init(stream: stream, first: first, allow: allow)
    }
    
    init(assert stream: TokenStream, allow: IdentifierAllowList) {
        let first = stream.consumeOne(if: { allow.asFirst.contains($0.type) }) ?? stream.consumeOne(assert: .word, recoveryDefault: "")
        self.init(stream: stream, first: first, allow: allow)
    }
    
    private init(stream: TokenStream, first: Token, allow: IdentifierAllowList) {
        self.tokens = [first]
        while let next = stream.consumeOne(if: { allow.next.contains($0.type) }) {
            self.tokens.append(next)
        }
        self.identifier = self.tokens.map(\.literal).joined(separator: " ")
    }
}

struct IdentifierAllowList {
    var asFirst: [TokenType]
    var next: [TokenType]
}

extension IdentifierAllowList {
    private static let basicFirst: [TokenType] = [.word, .numberPrefixedWord]
    private static let basicNext: [TokenType] = basicFirst + [.number]
    
    static let inBinding = IdentifierAllowList(asFirst: basicFirst + [.keyword(.where)], next: basicNext + [.keyword(.where)])
    static let inTypeName = IdentifierAllowList(asFirst: basicFirst, next: basicNext)
}
