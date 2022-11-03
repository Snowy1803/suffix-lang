//
//  ASTNode+Rainbow.swift
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

extension ASTNode {
    func dumpAST(indent: String = "") -> String {
        let nextIndent = indent + "  "
        let data = (nodeData?.green).map { ": \($0)" } ?? ""
        let position = nodePosition.map { " (\($0.line):\($0.char))".blue } ?? ""
        return "\(nodeType.magenta)\(data)\(position)\n" + nodeChildren.map { element -> String in
            let elem: String
            if element.value.isEmpty {
                elem = "(none)\n"
            } else if element.value.count == 1 {
                elem = element.value[0].dumpAST(indent: nextIndent)
            } else {
                elem = "\n" + element.value.map {
                    let contentIndent = nextIndent + "  "
                    return "\(contentIndent)- " + $0.dumpAST(indent: contentIndent)
                }.joined()
            }
            return "\(nextIndent)- \(element.name.red): \(elem)"
        }.joined()
    }
}
