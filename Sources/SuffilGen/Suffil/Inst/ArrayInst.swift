//
//  ArrayInst.swift
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

final class ArrayInst {
    var array: LocatedLocalRef
    var elementType: SType
    var elements: [LocatedRef]
    
    init(array: LocatedLocalRef, elementType: SType, elements: [LocatedRef]) {
        self.array = array
        self.elementType = elementType
        self.elements = elements
    }
}

extension ArrayInst: InstProtocol {
    var description: String {
        "\(array) = array [\(elementType)] (\(elements.map(\.description).joined(separator: ", ")))"
    }
    
    var definingRefs: [LocatedLocalRef] { [array] }
    var usingRefs: [LocatedRef] { elements }
    func replaceOccurrences(of target: Ref, with replacement: Ref) {
        elements.formMap {
            $0.value.replaceOccurrences(of: target, with: replacement)
        }
    }
}
