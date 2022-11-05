//
//  Parser.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 22/10/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public class Parser {
    var stream: TokenStream
    
    public var diagnostics: [Diagnostic] {
        stream.diagnostics
    }
    
    public init(tokens: [Token]) {
        self.stream = TokenStream(tokens: tokens)
    }
    
    public func parse() -> BlockContent {
        defer {
            if let remainingToken = stream.consumeOne() {
                stream.diagnostics.append(Diagnostic(token: remainingToken, message: ParserDiagnosticMessage.invalidToken, severity: .fatal))
            }
        }
        return BlockContent(stream: stream)
    }
}
