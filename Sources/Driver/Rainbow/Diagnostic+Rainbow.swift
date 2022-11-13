//
//  Diagnostic+Rainbow.swift
//  Graphism CLI
//
//  Created by Emil Pedersen on 09/09/2021.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Rainbow
import SuffixLang

extension Diagnostic.Severity {
    var colorfulDescription: String {
        let desc = String(describing: self)
        switch self {
        case .info, .hint:
            return desc.blue
        case .warning:
            return desc.yellow
        case .error, .fatal:
            return desc.red
        }
    }
}

extension Diagnostic {
    func representNicely(filepath: String) -> String {
        // remove tabs as they mess everything up with their wider size
        let base = startPosition.getFullLine(document: document)
        var msg = "\((filepath as NSString).lastPathComponent):\(startPosition.line):\(startPosition.char): \(severity.colorfulDescription): \(message)\n"
        msg += base.replacingOccurrences(of: "\t", with: " ")
        msg += String(repeating: " ", count: max(0, startPosition.char - 1))
        msg += "^" + String(repeating: "~", count: max(0, literal.count - 1))
        msg += "\n"
        for hint in hints {
            msg += hint.representNicely(filepath: filepath)
        }
        return msg
    }
}
