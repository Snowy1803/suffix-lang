//
//  GRPHServer.swift
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
import LanguageServerProtocolJSONRPC
import LSPLogging
import SuffixLang
import Sema

class SuffixServer: MessageHandler {
    
    let client: JSONRPCConnection
    let queue: DispatchQueue = DispatchQueue(label: "language-server-queue", qos: .userInitiated)
    
    var root: DocumentURI!
    var documents: [DocumentURI: Document] = [:]
    
    init(client: JSONRPCConnection) {
        self.client = client
    }
    
    func handle<Notification>(_ notif: Notification, from: ObjectIdentifier) where Notification : NotificationType {
        log("received: \(notif)", level: .debug)
        queue.async { [unowned self] in
            switch notif {
            case is ExitNotification:
                client.close()
            case let notif as DidOpenTextDocumentNotification:
                didOpenDocument(notif)
            case let notif as DidChangeTextDocumentNotification:
                didChangeDocument(notif)
            case let notif as DidCloseTextDocumentNotification:
                didCloseDocument(notif)
            case is DidSaveTextDocumentNotification, is InitializedNotification:
                break // ignore
            default:
                log("unknown notif \(notif)", level: .warning)
            }
        }
    }
    
    func handle<R>(_ params: R, id: RequestID, from clientID: ObjectIdentifier, reply: @escaping (LSPResult<R.Response>) -> Void) where R : RequestType {
        log("received: \(id): \(params)", level: .debug)
        queue.async { [unowned self] in
            let cancellationToken = CancellationToken()

            let request = Request(params, id: id, clientID: clientID, cancellation: cancellationToken, reply: reply)

            switch request {
            case let request as Request<InitializeRequest>:
                initialize(request)
            case let request as Request<ShutdownRequest>:
                request.reply(VoidResponse()) // ignore
            case let request as Request<HoverRequest>:
                hover(request)
            case let request as Request<DocumentSemanticTokensRequest>:
                semanticTokens(request)
//            case let request as Request<DefinitionRequest>:
//                jumpToDefinition(request, position: request.params.position)
//            case let request as Request<ImplementationRequest>:
//                jumpToDefinition(request, position: request.params.position)
//            case let request as Request<ReferencesRequest>:
//                findReferences(request)
//            case let request as Request<DocumentHighlightRequest>:
//                highlightReferences(request)
//            case let request as Request<DocumentSymbolRequest>:
//                outline(request)
//            case let request as Request<PrepareRenameRequest>:
//                prepareRename(request)
//            case let request as Request<RenameRequest>:
//                rename(request)
//            case let request as Request<DocumentColorRequest>:
//                findStaticColors(request)
//            case let request as Request<ColorPresentationRequest>:
//                presentColor(request)
            case let request as Request<CompletionRequest>:
                autocomplete(request)
//            case let request as Request<CallHierarchyPrepareRequest>:
//                prepareCallHierarchy(request)
//            case let request as Request<CallHierarchyIncomingCallsRequest>:
//                incomingCallHierarchy(request)
//            case let request as Request<CallHierarchyOutgoingCallsRequest>:
//                outgoingCallHierarchy(request)
            default:
                log("unknown request \(request)")
            }
        }
    }
    
    func initialize(_ request: Request<InitializeRequest>) {
        root = request.params.rootURI ?? request.params.rootPath.map { DocumentURI(URL(fileURLWithPath: $0)) }
        request.reply(.success(InitializeResult(capabilities: ServerCapabilities(
            textDocumentSync: .options(TextDocumentSyncOptions(
                openClose: true,
                change: .full,
                willSave: false)),
            hoverProvider: .bool(true),
            completionProvider: CompletionOptions(resolveProvider: false, triggerCharacters: ["."]),
            signatureHelpProvider: nil, // provide parameter completion (no)
            definitionProvider: .bool(false), // jump to definition
            implementationProvider: .bool(false), // jump to symbol implementation
            referencesProvider: .bool(false), // view all references to symbol
            documentHighlightProvider: .bool(false), // view all references to symbol, for highlighting
            documentSymbolProvider: .bool(false), // list all symbols
            workspaceSymbolProvider: .bool(false), // we are single-file
            codeActionProvider: .bool(false), // actions, such as refactors or quickfixes
            renameProvider: .value(RenameOptions(prepareProvider: false)),
            colorProvider: .bool(false),
            foldingRangeProvider: .bool(false), // fold imports & long doc comments
            callHierarchyProvider: .bool(false),
            semanticTokensProvider: SemanticTokensOptions(
                legend: SemanticTokensLegend(
                    tokenTypes: LSPSemanticTokenType.allCases.map(\.name),
                    tokenModifiers: []),
                range: .bool(false),
                full: .value(.init(delta: false)))))))
    }
    
    // MARK: - Text sync
    
    func didOpenDocument(_ notif: DidOpenTextDocumentNotification) {
        let doc = Document(item: notif.textDocument)
        documents[notif.textDocument.uri] = doc
        doc.ensureTokenized(publisher: self)
    }
    
    func didChangeDocument(_ notif: DidChangeTextDocumentNotification) {
        guard let doc = documents[notif.textDocument.uri] else {
            log("change text in closed document", level: .error)
            return
        }
        doc.handle(notif)
        queue.asyncAfter(deadline: .now() + 1) { [weak doc] in
            doc?.ensureTokenized(publisher: self)
        }
    }
    
    func didCloseDocument(_ notif: DidCloseTextDocumentNotification) {
        documents[notif.textDocument.uri] = nil
    }
    
    // MARK: Diagnostics
    
    func publishDiagnostics(_ diag: [Diagnostic], for doc: Document) {
        client.send(PublishDiagnosticsNotification(uri: doc.item.uri, version: doc.item.version, diagnostics: diag.map { $0.toLSP(doc: doc.item.uri) }))
    }
    
    // MARK: - Requests
    
    func ensureDocTokenized<T>(request: Request<T>) -> TokenizedDocument? where T: TextDocumentRequest {
        guard let doc = documents[request.params.textDocument.uri] else {
            request.reply(.failure(.unknown("document not open")))
            return nil
        }
        
        doc.ensureTokenized(publisher: self)
        
        guard let tokenized = doc.tokenized else {
            request.reply(.failure(.unknown("tokenization error")))
            return nil
        }
        return tokenized
    }
    
    func hover(_ request: Request<HoverRequest>) {
        guard let tokenized = ensureDocTokenized(request: request) else {
            return
        }
        
//        guard let doc = tokenized.documentation else {
            request.reply(.failure(.unknown("tokenization error")))
            return
//        }
//
//        guard let token = doc.semanticTokens.last(where: { $0.token.positionRangeClosed.contains(request.params.position) }),
//              let documentation = doc.findDocumentation(token: token) else {
//            request.reply(.success(nil))
//            return
//        }
//
//        request.reply(.success(HoverResponse(contents: HoverResponseContents.markupContent(MarkupContent(kind: .markdown, value: documentation.markdown)), range: token.token.positionRange)))
    }
    
    func semanticTokens(_ request: Request<DocumentSemanticTokensRequest>) {
        guard let tokenized = ensureDocTokenized(request: request) else {
            return
        }
        
        let lspTokens = tokenized.semanticTokens.sorted()
        
        var line: Int = 0
        var character: Int = 0
        var collect: [UInt32] = []
        collect.reserveCapacity(lspTokens.count * 5)
        for lspToken in lspTokens {
            collect.append(contentsOf: lspToken.generateData(line: &line, character: &character))
        }
        
        request.reply(.success(DocumentSemanticTokensResponse(resultId: nil, data: collect)))
    }
    
    // MARK: Find Requests
    
//    func jumpToDefinition<T>(_ request: Request<T>, position: Position) where T: TextDocumentRequest, T.Response == LocationsOrLocationLinksResponse? {
//        guard let tokenized = ensureDocTokenized(request: request) else {
//            return
//        }
//
//        guard let symbol = tokenized.documentation?.semanticTokens.first(where: { $0.token.positionRangeClosed.contains(position) }),
//              let decl = tokenized.documentation?.findDeclaration(for: symbol) else {
//            request.reply(.success(nil))
//            return
//        }
//
//        request.reply(.success(.locations([Location(uri: request.params.textDocument.uri, range: decl.token.positionRange)])))
//    }
//
//    func findReferences(_ request: Request<ReferencesRequest>) {
//        guard let tokenized = ensureDocTokenized(request: request) else {
//            return
//        }
//
//        guard let doc = tokenized.documentation,
//              let symbol = doc.semanticTokens.first(where: { $0.token.positionRangeClosed.contains(request.params.position) }) else {
//            request.reply(.success([]))
//            return
//        }
//
//        request.reply(.success(doc.findReferences(of: symbol).map({
//            Location(uri: request.params.textDocument.uri, range: $0.token.positionRange)
//        })))
//    }
//
//    func highlightReferences(_ request: Request<DocumentHighlightRequest>) {
//        guard let tokenized = ensureDocTokenized(request: request) else {
//            return
//        }
//
//        guard let doc = tokenized.documentation,
//              let symbol = doc.semanticTokens.first(where: { $0.token.positionRangeClosed.contains(request.params.position) }) else {
//            request.reply(.success([]))
//            return
//        }
//
//        request.reply(.success(doc.findReferences(of: symbol).map({
//            DocumentHighlight(range: $0.token.positionRange, kind: $0.modifiers.contains(.modification) ? .write : .read)
//        })))
//    }
//
//    /// Used for outline and breadcrumbs: Return an outline, as a tree
//    /// Our CST doesn't use indentation to make trees
//    /// Our I&E, however, can be used to populate this
//    func outline(_ request: Request<DocumentSymbolRequest>) {
//        guard let tokenized = ensureDocTokenized(request: request) else {
//            return
//        }
//
//        request.reply(.success(.documentSymbols(tokenized.instructions.outline(lexedLines: tokenized.lexed, semanticTokens: tokenized.documentation?.semanticTokens ?? []))))
//    }
//
//    // MARK: Rename Requests
//
//    func prepareRename(_ request: Request<PrepareRenameRequest>) {
//        guard let tokenized = ensureDocTokenized(request: request) else {
//            return
//        }
//
//        guard let symbol = tokenized.documentation?.semanticTokens.first(where: { $0.token.positionRangeClosed.contains(request.params.position) }),
//              tokenized.documentation?.findDeclaration(for: symbol) != nil else {
//            request.reply(.success(nil)) // no symbol, or symbol is builtin
//            return
//        }
//
//        request.reply(.success(PrepareRenameResponse(range: symbol.token.positionRange)))
//    }
//
//    func rename(_ request: Request<RenameRequest>) {
//        guard let tokenized = ensureDocTokenized(request: request) else {
//            return
//        }
//
//        guard let doc = tokenized.documentation,
//              let symbol = doc.semanticTokens.first(where: { $0.token.positionRangeClosed.contains(request.params.position) }),
//              doc.findDeclaration(for: symbol) != nil else {
//            request.reply(.success(nil)) // should've been catched by prepare, but maybe client doesn't support it
//            return
//        }
//
//        // check valid identifier
//        let lexer = GRPHLexer()
//        let line = lexer.parseLine(lineNumber: 0, content: request.params.newName)
//        guard line.children.count == 2, line.children[1].tokenType == .identifier else {
//            request.reply(.failure(ResponseError(code: .invalidParams, message: "Invalid identifier given")))
//            return
//        }
//
//        request.reply(.success(WorkspaceEdit(changes: [
//            request.params.textDocument.uri: doc.findReferences(of: symbol).map {
//                TextEdit(range: $0.token.positionRange, newText: request.params.newName)
//            }
//        ])))
//    }
    
    // MARK: Autocomplete
    
    func autocomplete(_ request: Request<CompletionRequest>) {
        guard let tokenized = ensureDocTokenized(request: request) else {
            return
        }
        
        let pos = request.params.position
//        let line = tokenized.lexed.first(where: { $0.lineNumber == pos.line })
        
        var items: [CompletionItem] = []
        
        if pos.utf16index == 0 {
            // instructions templates
            items.append(CompletionItem(label: "Create a Function", kind: .snippet, detail: "func name () () {}", insertText: """
                func ${1:name} () () {
                    ${2:body}
                }
                """, insertTextFormat: .snippet))
            items.append(CompletionItem(label: "Create a Record", kind: .snippet, detail: "record name {}", insertText: """
                record ${1:name} {
                    ${2:body}
                }
                """, insertTextFormat: .snippet))
            items.append(CompletionItem(label: "Create an Enum", kind: .snippet, detail: "enum name {}", insertText: """
                enum ${1:name} {
                    ${2:body}
                }
                """, insertTextFormat: .snippet))
            items.append(CompletionItem(label: "Create a Binding", kind: .snippet, detail: "value > name", insertText: "${1:value} > ${2:name}", insertTextFormat: .snippet))
        }
        
        for binding in tokenized.scopedBindings {
            if binding.isInScope(at: pos) {
                items.append(CompletionItem(label: binding.binding.name, kind: binding.binding.completionKind, insertText: binding.binding.name))
            }
        }
        
        request.reply(.success(CompletionList(isIncomplete: false, items: items)))
    }
    
    // MARK: Call Hierarchy
    
//    func prepareCallHierarchy(_ request: Request<CallHierarchyPrepareRequest>) {
//        guard let tokenized = ensureDocTokenized(request: request) else {
//            return
//        }
//
//        guard let doc = tokenized.documentation,
//              let token = doc.semanticTokens.last(where: { $0.token.positionRangeClosed.contains(request.params.position) }) else {
//            request.reply(.success(nil)) // invalid selection
//            return
//        }
//
//        if let item = callHierarchyItem(token: token, document: documents[request.params.textDocument.uri]!) {
//            request.reply(.success([item]))
//        } else {
//            request.reply(.success([])) // may be an error, but those are logged anyway
//        }
//    }
//
//    func findSymbol(for token: SemanticToken, in outline: [DocumentSymbol]) -> (path: [Int], symbol: DocumentSymbol)? {
//        for (index, ds) in outline.enumerated() {
//            if ds.range.contains(token.token.startPosition) && ds.kind != .variable {
//                if let (path, result) = findSymbol(for: token, in: ds.children ?? []) {
//                    return ([index] + path, result)
//                } else {
//                    return ([index], ds)
//                }
//            }
//        }
//        return nil
//    }
//
//    func incomingCallHierarchy(_ request: Request<CallHierarchyIncomingCallsRequest>) {
//        let item = request.params.item
//        guard item.kind != .file else {
//            request.reply(.success([]))
//            return
//        }
//
//        let declDoc: DocGenerator?
//        if item.uri.scheme == "grphbuiltin" {
//            declDoc = DocGenerator.builtins
//        } else {
//            declDoc = documents[item.uri]?.tokenized?.documentation
//        }
//
//        guard let decl = declDoc?.semanticTokens.first(where: { $0.token.positionRange == item.selectionRange }) else {
//            request.reply(.failure(.unknown("could not find item")))
//            return
//        }
//
//        var result: [CallHierarchyIncomingCall] = []
//        for doc in documents.values {
//            if let tokenized = doc.tokenized,
//               let documentation = tokenized.documentation {
//                let outline = tokenized.instructions.outline(lexedLines: tokenized.lexed, semanticTokens: documentation.semanticTokens)
//
//                var partial: [[Int]: CallHierarchyIncomingCall] = [:]
//
//                let script = CallHierarchyItem(script: doc.item.uri, lines: tokenized.lexed.count)
//
//                for st in documentation.semanticTokens.filter({ documentation.areTheSameMember(decl, $0) && $0.modifiers.contains(.call) }) {
//                    let (path, symbol) = findSymbol(for: st, in: outline).map { ($0, CallHierarchyItem(symbol: $1, uri: doc.item.uri)) } ?? ([], script)
//                    let range = st.token.positionRange
//                    if var parent = partial[path] {
//                        parent.fromRanges.append(range)
//                        partial[path] = parent
//                    } else {
//                        partial[path] = CallHierarchyIncomingCall(from: symbol, fromRanges: [range])
//                    }
//                }
//
//                result += partial.values
//            }
//        }
//
//        request.reply(.success(result))
//    }
//
//    func outgoingCallHierarchy(_ request: Request<CallHierarchyOutgoingCallsRequest>) {
//        let item = request.params.item
//
//        if item.uri.scheme == "grphbuiltin" {
//            // a builtin doesn't call other functions
//            request.reply(.success([]))
//            return
//        }
//
//        guard let doc = documents[item.uri],
//              let tokenized = doc.tokenized,
//              let documentation = tokenized.documentation else {
//            request.reply(.failure(.unknown("could not find document")))
//            return
//        }
//
//        var result: [String: CallHierarchyOutgoingCall] = [:]
//
//        for st in documentation.semanticTokens.filter({ item.range.contains($0.token.startPosition) && $0.modifiers.contains(.call) }) {
//            let range = st.token.positionRange
//            guard let id = st.documentationIdentifier,
//                  let symbol = callHierarchyItem(token: st, document: doc) else {
//                continue
//            }
//            if var parent = result[id] {
//                parent.fromRanges.append(range)
//                result[id] = parent
//            } else {
//                result[id] = CallHierarchyOutgoingCall(to: symbol, fromRanges: [range])
//            }
//        }
//
//        request.reply(.success(Array(result.values)))
//    }
//
//    func callHierarchyItem(token: SemanticToken, document: Document) -> CallHierarchyItem? {
//        let tokenized = document.tokenized!
//        let doc = tokenized.documentation!
//        if let decl = doc.findDeclaration(for: token) {
//            let outline = tokenized.instructions.outline(lexedLines: tokenized.lexed, semanticTokens: doc.semanticTokens)
//
//            if let symbol = findSymbol(for: decl, in: outline)?.symbol {
//                return CallHierarchyItem(symbol: symbol, uri: document.item.uri)
//            } else { // should never happen
//                log("no document symbol for token", level: .error)
//                return nil
//            }
//        } else if let decl = DocGenerator.builtins.findDeclaration(for: token) {
//            let uri = DocumentURI(string: "grphbuiltin:///builtins.grph")
//            switch decl.data {
//            case .function(let fn):
//                return CallHierarchyItem(
//                    name: fn.name,
//                    kind: .function,
//                    tags: token.modifiers.contains(.deprecated) ? [.deprecated] : [],
//                    detail: fn.signature,
//                    uri: uri,
//                    range: decl.token.positionRange,
//                    selectionRange: decl.token.positionRange
//                )
//            case .method(let fn):
//                return CallHierarchyItem(
//                    name: fn.name,
//                    kind: .method,
//                    tags: token.modifiers.contains(.deprecated) ? [.deprecated] : [],
//                    detail: fn.signature,
//                    uri: uri,
//                    range: decl.token.positionRange,
//                    selectionRange: decl.token.positionRange
//                )
//            case .constructor(let fn):
//                return CallHierarchyItem(
//                    name: fn.name,
//                    kind: .constructor,
//                    tags: token.modifiers.contains(.deprecated) ? [.deprecated] : [],
//                    detail: fn.signature,
//                    uri: uri,
//                    range: decl.token.positionRange,
//                    selectionRange: decl.token.positionRange
//                )
//            case .variable(_), .property(_, in: _), .identifier(_):
//                return nil // normal
//            case .none:
//                log("could not find identifier", level: .error)
//                return nil
//            }
//        } else {
//            log("could not find token in document nor builtins", level: .error)
//            return nil
//        }
//    }
}

//extension CallHierarchyItem {
//    init(symbol: DocumentSymbol, uri: DocumentURI) {
//        self.init(name: symbol.name, kind: symbol.kind, tags: symbol.deprecated == true ? [.deprecated] : [], detail: symbol.detail, uri: uri, range: symbol.range, selectionRange: symbol.selectionRange)
//    }
//
//    init(script uri: DocumentURI, lines: Int) {
//        self.init(name: uri.fileURL?.lastPathComponent ?? "script", kind: .file, tags: nil, uri: uri, range: Position(line: 0, utf16index: 0)..<Position(line: lines, utf16index: 0), selectionRange: Position(line: 0, utf16index: 0)..<Position(line: lines, utf16index: 0))
//    }
//}
