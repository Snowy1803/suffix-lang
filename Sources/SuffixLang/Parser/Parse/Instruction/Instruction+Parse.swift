//
//  Instruction+Parse.swift
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

extension Instruction {
    init?(stream: TokenStream) {
        if let inst = BindInstruction(stream: stream) {
            self = .bind(inst)
        } else if let inst = CallInstruction(stream: stream) {
            self = .call(inst)
        } else if let inst = FunctionInstruction(stream: stream) {
            self = .function(inst)
        } else if let inst = RecordInstruction(stream: stream) {
            self = .record(inst)
        } else if let inst = EnumInstruction(stream: stream) {
            self = .enum(inst)
        } else if let inst = PushInstruction(stream: stream) {
            self = .push(inst)
        } else { // implicit push
            let state = stream.saveState()
            let value = Value(stream: stream)
            guard !stream.didErrorSince(state: state) else {
                stream.restore(state: state)
                return nil
            }
            self = .push(PushInstruction(op: Token(position: .missing, literal: "&", type: .pushOperator), value: value))
        }
    }
}
