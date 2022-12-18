//
//  Diagnostic+LSP.swift
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
import SuffixLang
import LanguageServerProtocol

typealias Diagnostic = SuffixLang.Diagnostic
typealias LSPDiagnostic = LanguageServerProtocol.Diagnostic

extension Diagnostic {
    /// Converts a Suffix Notice to an LSP Diagnostic
    /// - Parameter doc: the document
    /// - Returns: An LSP Diagnostic
    func toLSP(doc: DocumentURI) -> LSPDiagnostic {
        let rel: [DiagnosticRelatedInformation] = self.hints.map { hint in
            DiagnosticRelatedInformation(location: Location(uri: doc, range: hint.positionRange), message: hint.message.description)
        }
        return LSPDiagnostic(
            range: positionRange,
            severity: severity.lspValue,
            source: "suffix",
            message: message.description,
            tags: nil,
            relatedInformation: rel
        )
    }
    
    var positionRange: Range<Position> {
        tokens.first!.lspStartPos..<tokens.last!.lspEndPos
    }
}

extension Diagnostic.Severity {
    var lspValue: DiagnosticSeverity {
        switch self {
        case .hint:
            return .hint
        case .info:
            return .information
        case .warning:
            return .warning
        case .error, .fatal:
            return .error
        }
    }
}
