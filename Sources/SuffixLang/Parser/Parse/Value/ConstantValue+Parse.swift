//
//  ConstantValue+Parse.swift
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

extension IntegerValue {
    init?(stream: TokenStream) {
        guard let first = stream.consumeOne(type: .number) else {
            return nil
        }
        self.tokens = [first]
        while let next = stream.consumeOne(type: .number) {
            self.tokens.append(next)
        }
        self.integer = Int(self.tokens.map(\.literal.description).joined().filter(\.isNumber)) ?? 0
    }
}

extension FloatValue {
    init?(stream: TokenStream) {
        let state = stream.saveState()
        guard let first = stream.consumeOne(type: .number) else {
            return nil
        }
        self.tokens = [first]
        while let next = stream.consumeOne(type: .number) {
            self.tokens.append(next)
        }
        guard let dot = stream.consumeOne(type: .dotOperator),
              let decimal = stream.consumeOne(type: .number) else {
            stream.restore(state: state)
            return nil
        }
        self.tokens.append(dot)
        self.tokens.append(decimal)
        while let next = stream.consumeOne(type: .number) {
            self.tokens.append(next)
        }
        self.float = Double(self.tokens.map(\.literal.description).joined().filter { $0.isNumber || $0 == "." }) ?? 0
    }
}
