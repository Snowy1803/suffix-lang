//
//  Value+Parse.swift
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

extension Value {
    init(stream: TokenStream) {
        if let value = ConstantValue(stream: stream) {
            self = .constant(value)
        } else if let value = StringValue(stream: stream) {
            self = .string(value)
        } else if let value = AnonymousFunctionValue(stream: stream) {
            self = .anonymousFunc(value)
        } else {
            self = .reference(ReferenceValue(stream: stream))
        }
    }
}
