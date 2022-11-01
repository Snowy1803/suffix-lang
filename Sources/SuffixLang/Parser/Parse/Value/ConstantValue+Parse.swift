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

extension ConstantValue {
    init?(stream: TokenStream) {
        guard let token = stream.consumeOne(if: { $0.type == .integerLiteral || $0.type == .floatLiteral }) else {
            return nil
        }
        self.token = token
    }
}
