//
//  Document.swift
//  SuffixLang LSP
// 
//  Created by Emil Pedersen on 24/09/2021.
//  Copyright © 2020 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LanguageServerProtocol
import LSPLogging
import SuffixLang
import Sema

/// Represents a suffix file
class Document {
    var item: TextDocumentItem
    var tokenized: TokenizedDocument?
    
    init(item: TextDocumentItem) {
        self.item = item
    }
    
    func handle(_ notif: DidChangeTextDocumentNotification) {
        item.version = notif.textDocument.version
        for change in notif.contentChanges {
            if change.range != nil {
                log("Text change range shouldn't be specified as we only accept full files", level: .error)
            }
            item.text = change.text
        }
        tokenized = nil
    }
    
    func ensureTokenized(publisher: SuffixServer) {
        if tokenized == nil {
            tokenized = TokenizedDocument(text: item.text)
            publisher.publishDiagnostics(tokenized!.diagnostics, for: self)
        }
    }
}

/// A processed suffix file
struct TokenizedDocument {
    
    var diagnostics: [Diagnostic]
    var tokens: [Token]
    var rootBlock: BlockContent
    var functions: [Function]
    var semanticTokens: [LSPToken]
    
    init(text: String) {
        log("Lexing", level: .debug)
        let lexer = Lexer(document: text)
        tokens = lexer.parseDocument()
        log("Parsing", level: .debug)
        let parser = Parser(tokens: tokens)
        rootBlock = parser.parse()
        diagnostics = parser.diagnostics
        log("Type Checking", level: .debug)
        let sema = TypeChecker(rootBlock: rootBlock)
        sema.passes = TypeChecker.lspPasses
        let collector = SemaLogCollector()
        sema.logger.destinations.append(collector)
        sema.typecheck()
        functions = sema.functions
        diagnostics.append(contentsOf: sema.diagnostics)
        semanticTokens = collector.semanticTokens
        log("Processed", level: .debug)
    }
}
