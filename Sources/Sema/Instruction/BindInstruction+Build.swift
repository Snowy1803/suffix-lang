//
//  BindInstruction+Build.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 19/11/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

extension BindInstruction {
    func buildInstruction(context: FunctionParsingContext) {
        guard let value = context.pop(count: 1, source: [op]).first else {
            return
        }
        // TODO: create inst for converting to appropriate type
        let target = self.value.typeAnnotation?.type.resolve(context: context) ?? value.type
        let rename = context.builder.buildRename(value: value.ref, type: target, name: self.value.literal.identifier)
        context.bindings.append(Binding(name: self.value.literal.identifier, type: target, source: .binding(self), ref: rename))
    }
}
