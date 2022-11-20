//
//  SuffilBuilder.swift
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

class SuffilBuilder {
    var function: Function
    
    init(function: Function) {
        self.function = function
    }
    
    func insert(inst: Inst) {
        function.instructions.append(inst)
    }
    
    func buildArray(elementType: SType, elements: [Ref]) -> Ref {
        let inst = ArrayInst(array: LocalRef(givenName: "", type: ArrayType(element: elementType)), elementType: elementType, elements: elements)
        insert(inst: .array(inst))
        return .local(inst.array)
    }
    
    func buildCall(value: Ref, type: FunctionType, parameters: [Ref]) -> [Ref] {
        let inst = CallInst(
            returning: type.returning.map { arg in LocalRef(givenName: "", type: arg.type) },
            function: value, parameters: parameters)
        insert(inst: .call(inst))
        return inst.returning.map { .local($0) }
    }
    
    func buildCopy(value: Ref, type: SType) -> Ref {
        let inst = CopyInst(copy: LocalRef(givenName: "", type: type), original: value)
        insert(inst: .copy(inst))
        return .local(inst.copy)
    }
    
    func buildRename(value: Ref, type: SType, name: String) -> Ref {
        let inst = RenameInst(newName: LocalRef(givenName: name, type: type), oldName: value)
        insert(inst: .rename(inst))
        return .local(inst.newName)
    }
    
    func buildRet(values: [Ref]) {
        let inst = RetInst(values: values)
        insert(inst: .ret(inst))
    }
}
