//
//  Identifier.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 22/10/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public struct Identifier: ASTNode {
    public var token: Token
    
    public var identifier: String {
        if case .identifier(let id) = token.data {
            return id
        }
        // happens in the case of a synthesized missing token (will probs be empty str)
        return token.literal.description
    }
}
