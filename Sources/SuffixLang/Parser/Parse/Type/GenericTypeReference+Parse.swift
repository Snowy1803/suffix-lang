//
//  GenericTypeReference+Parse.swift
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

extension GenericTypeReference {
    init?(stream: TokenStream) {
        guard let identifier = stream.consumeOne(type: .identifier) else {
            return nil
        }
        self.name = identifier
        if let generics = GenericTypeArguments(stream: stream) {
            self.generics = generics
        }
    }
}

extension GenericTypeArguments {
    init?(stream: TokenStream) {
        guard let open = stream.consumeOne(type: .bracketOpen) else {
            return nil
        }
        self.open = open
        self.generics = []
        while let generic = Generic(stream: stream) {
            self.generics.append(generic)
        }
        self.close = stream.consumeOne(assert: .bracketClose, recoveryDefault: "]")
    }
}

extension GenericTypeArguments.Generic {
    init?(stream: TokenStream) {
        guard let type = TypeReference(stream: stream) else {
            return nil
        }
        self.type = type
        if let comma = stream.consumeOne(type: .comma) {
            self.trailingComma = comma
        }
    }
}

extension GenericDefinition {
    init?(stream: TokenStream) {
        guard let open = stream.consumeOne(type: .bracketOpen) else {
            return nil
        }
        self.open = open
        self.generics = []
        while let generic = Generic(stream: stream) {
            self.generics.append(generic)
        }
        self.close = stream.consumeOne(assert: .bracketClose, recoveryDefault: "]")
    }
}

extension GenericDefinition.Generic {
    init?(stream: TokenStream) {
        guard let type = stream.consumeOne(type: .identifier) else {
            return nil
        }
        self.name = type
        if let comma = stream.consumeOne(type: .comma) {
            self.trailingComma = comma
        }
    }
}
