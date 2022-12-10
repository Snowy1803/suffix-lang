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
    var asFirst: Set<TokenType>
    var next: Set<TokenType>
}

extension IdentifierAllowList {
    private static let basicFirst: Set<TokenType> = [.word, .numberPrefixedWord]
    private static let basicNext: Set<TokenType> = basicFirst + [.number]
    private static let instStarterKeywords: Set<TokenType> = [.keyword(.record), .keyword(.enum), .keyword(.func), .keyword(.trait), .keyword(.conform), .keyword(.typealias)]
    
    /// Only basic words and the `where` keyword are allowed in binding names
    static let inBinding = IdentifierAllowList(asFirst: basicFirst + [.keyword(.where)], next: basicNext + [.keyword(.where)])
    /// Only basic words are allowed in type names
    static let inTypeName = IdentifierAllowList(asFirst: basicFirst, next: basicNext)
    /// Everything is allowed in trait names, except `where` as first word
    static let inTraitName = IdentifierAllowList(asFirst: basicFirst + instStarterKeywords, next: basicNext + instStarterKeywords + [.keyword(.where)])
}

private extension Set {
    static func + (lhs: Set, rhs: Set) -> Set {
        return lhs.union(rhs)
    }
}
