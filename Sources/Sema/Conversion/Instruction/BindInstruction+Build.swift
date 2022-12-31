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
    func buildInstruction(context: FunctionParsingContext) -> BindStmt {
        let value = context.pop(count: 1, source: nodeAllTokens).first
        let target = self.value.typeAnnotation?.type.resolve(context: context) ?? value?.value.type ?? context.constraints.createUnresolvedType()
        let content = value.map({ TBinding.Content.element($0)}) ?? .error
        if let value {
            context.constraints.constrain(type: value.value.type, convertibleTo: target)
        }
        let binding = TBinding(name: self.value.literal.identifier, type: target, source: .binding(self), content: content)
        context.add(global: false, binding: binding)
        return BindStmt(binding: binding, source: self)
    }
}
