//
//  Token+Rainbow.swift
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

extension Token {
    var dumped: String {
        return "\(literal.debugDescription.red) \(String(describing: type).magenta) (\(position.line):\(position.char)) \(data?.dumped ?? "")\n"
    }
}

extension Token.AssociatedData {
    var dumped: String {
        switch self {
        case .interpolation(let array):
            return array.map({
                switch $0 {
                case .literal(let value):
                    return value.debugDescription.red
                case .escaped(let value):
                    return value.description.magenta
                case .percent(let value):
                    return value.description.blue
                }
            }).joined()
        }
    }
}
