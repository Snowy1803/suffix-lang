//
//  TokenStream.swift
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

class TokenStream {
    private var tokens: [Token]
    private(set) var slice: ArraySlice<Token>
    var diagnostics: [Diagnostic] = []
    /// these token types are always silently skipped
    var skipTokenTypes: [TokenType] = [.comment, .whitespace]
    /// these token types are always skipped with an error
    var invalidTokenTypes: [TokenType] = [.unresolved, .twoDots, .coercingOperator]
    
    init(tokens: [Token]) {
        self.tokens = tokens
        self.slice = tokens[...]
    }
    
    var document: String {
        tokens.first?.literal.base ?? ""
    }
    
    func saveState() -> RestorableState {
        RestorableState(slice: slice, diagnostics: diagnostics)
    }
    
    func restore(state: RestorableState) {
        self.slice = state.slice
        self.diagnostics = state.diagnostics
    }
    
    func didErrorSince(state: RestorableState) -> Bool {
        return diagnostics.filter({ $0.severity >= .error }).count > state.diagnostics.filter({ $0.severity >= .error }).count
    }
    
    var isExhausted: Bool {
        slice.isEmpty
    }
    
    func consumeOne(if condition: (Token) -> Bool) -> Token? {
        func impl(condition: (Token) -> Bool) -> Token? {
            guard let token = slice.first, condition(token) else {
                return nil
            }
            slice = slice[(slice.startIndex + 1)...]
            return token
        }
        while let token = impl(condition: {
            skipTokenTypes.contains($0.type) || invalidTokenTypes.contains($0.type)
        }) {
            if invalidTokenTypes.contains(token.type) {
                diagnostics.append(Diagnostic(token: token, message: ParserDiagnosticMessage.invalidToken, severity: .error))
            }
        }
        return impl(condition: condition)
    }
    
    func consumeOne() -> Token? {
        return consumeOne(if: { _ in true })
    }
    
    func consumeOne(type: TokenType) -> Token? {
        return consumeOne(if: { $0.type == type })
    }
    
    func consumeOne(type: TokenType, literal: String) -> Token? {
        return consumeOne(if: { $0.type == type && $0.literal == literal })
    }
    
    func consumeOne(assert type: TokenType, literal: String) -> Token {
        if let correct = consumeOne(type: type, literal: literal) {
            return correct
        }
        diagnostics.append(Diagnostic(token: slice.first ?? .onePastEnd(document: document), message: ParserDiagnosticMessage.expectedToken(literal: literal), severity: .error))
        return Token(position: .missing, literal: literal[...], type: type)
    }
    
    func consumeOne(assert type: TokenType, recoveryDefault: @autoclosure () -> String) -> Token {
        if let correct = consumeOne(type: type) {
            return correct
        }
        diagnostics.append(Diagnostic(token: slice.first ?? .onePastEnd(document: document), message: ParserDiagnosticMessage.expectedTokenType(type), severity: .error))
        return Token(position: .missing, literal: recoveryDefault()[...], type: type)
    }
    
    func nextTokenForDiagnostics() -> Token {
        peekNext() ?? .onePastEnd(document: document)
    }
    
    func peekNext() -> Token? {
        let state = saveState()
        defer { restore(state: state) }
        return consumeOne()
    }
    
    func peekNext(type: TokenType) -> Bool {
        return peekNext()?.type == type
    }
    
    struct RestorableState {
        fileprivate var slice: ArraySlice<Token>
        fileprivate var diagnostics: [Diagnostic]
    }
}
