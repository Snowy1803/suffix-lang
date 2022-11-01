//
//  Block+Parse.swift
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

extension Block {
    init(stream: TokenStream) {
        self.open = stream.consumeOne(assert: .curlyOpen, literal: "{")
        self.content = BlockContent(stream: stream)
        self.close = stream.consumeOne(assert: .curlyClose, literal: "}")
    }
}

extension BlockContent {
    init(stream: TokenStream) {
        self.instructions = []
        while let instruction = Instruction(stream: stream) {
            instructions.append(instruction)
        }
    }
}

extension RecordBlock {
    init(stream: TokenStream) {
        self.open = stream.consumeOne(assert: .curlyOpen, literal: "{")
        self.content = []
        while let instruction = BindInstruction(stream: stream) {
            content.append(instruction)
        }
        self.close = stream.consumeOne(assert: .curlyClose, literal: "}")
    }
}
