//
//  FunctionInstruction+Parse.swift
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

extension FunctionInstruction {
    init?(stream: TokenStream) {
        guard let op = stream.consumeOne(type: .keyword, literal: "func") else {
            return nil
        }
        self.keyword = op
        self.name = stream.consumeOne(assert: .identifier, recoveryDefault: "missing \(UUID())")
        self.arguments = FunctionTypeReference.Arguments(assert: stream)
        self.returning = FunctionTypeReference.Arguments(assert: stream)
        self.block = Block(stream: stream)
    }
}