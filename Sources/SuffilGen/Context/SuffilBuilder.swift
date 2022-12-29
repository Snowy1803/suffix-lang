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
import SuffixLang

class SuffilBuilder {
    var function: Function
    
    init(function: Function) {
        self.function = function
    }
    
    func insert(inst: Inst) {
        function.instructions.append(inst)
    }
    
    func buildArray(elementType: SType, elements: [LocatedRef]) -> Ref {
        let inst = ArrayInst(
            array: LocalRef(givenName: "", type: ArrayType(element: elementType)).noLocation,
            elementType: elementType,
            elements: elements
        )
        insert(inst: .array(inst))
        return .local(inst.array.value)
    }
    
    func buildCallReturnInst(value: LocatedRef, type: FunctionType, parameters: [LocatedRef]) -> CallInst {
        let inst = CallInst(
            returning: type.returning.map { arg in LocalRef(givenName: "", type: arg.type).noLocation },
            function: value,
            parameters: parameters
        )
        insert(inst: .call(inst))
        return inst
    }
    
    func buildCall(value: LocatedRef, type: FunctionType, parameters: [LocatedRef]) -> [Ref] {
        let inst = buildCallReturnInst(value: value, type: type, parameters: parameters)
        return inst.returning.map { .local($0.value) }
    }
    
    func buildCopy(value: LocatedRef, type: SType) -> Ref {
        if value.value.isConstant {
            return value.value
        }
        let inst = CopyInst(copy: LocalRef(givenName: "", type: type).noLocation, original: value)
        insert(inst: .copy(inst))
        return .local(inst.copy.value)
    }
    
    func buildRename(value: Ref, type: SType, name: String) -> Ref {
        if case .local(let local) = value {
            local.givenName = name
        }
        return value
    }
    
    func buildClosure(function lfunction: LocatedFunction) -> Ref {
        let function = lfunction.value
        let const = Ref.function(function)
        if function.traits.traits[.function(.noCapture)] != nil {
            return const // function with 'no capture' trait don't need a closure
        }
        if function.notBuilt {
            var diagnostics: [Diagnostic] = []
            function.traits.add(trait: TraitContainer.TraitInfo(trait: .function(.noCapture), source: .implicitlyConstrained(lfunction.node!, reason: .functionUsedBeforeDefinition)), diagnostics: &diagnostics)
            assert(diagnostics.isEmpty, "Adding 'no capture' cannot fail")
            return const
        }
        let inst = ClosureInst(name: LocalRef(givenName: "\(function.name) closure", type: function.type).noLocation, function: lfunction)
        insert(inst: .closure(inst))
        return .local(inst.name.value)
    }
    
    func buildDestroy(value: LocatedRef) {
        if value.value.isConstant {
            return
        }
        let inst = DestroyInst(value: value)
        insert(inst: .destroy(inst))
    }
    
    func buildRet(values: [LocatedRef]) {
        let inst = RetInst(values: values)
        insert(inst: .ret(inst))
    }
}
