//
//  LocalRef.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 12/11/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

final class LocalRef {
    let givenName: String
    let type: SType
    var seqNumber: Int?
    
    init(givenName: String, type: SType) {
        self.givenName = givenName
        self.type = type
    }
    
    func assignNumber(with numberer: inout LocalRefNumberer) {
        seqNumber = numberer.getNumber(givenName: givenName)
    }
}

extension LocalRef: CustomStringConvertible {
    var description: String {
        "%\(givenName)\(seqNumber.map(String.init) ?? ""): \(type)"
    }
}

extension LocalRef: Equatable, Hashable {
    static func ==(_ lhs: LocalRef, _ rhs: LocalRef) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

struct LocalRefNumberer {
    var numbers: [String: Int]
    
    init() {
        self.numbers = ["": 0]
    }
    
    mutating func getNumber(givenName: String) -> Int? {
        let number = numbers[givenName]
        numbers[givenName] = (number ?? 1) + 1
        return number
    }
}
