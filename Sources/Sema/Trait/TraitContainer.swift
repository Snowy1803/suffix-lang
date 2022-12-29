//
//  TraitContainer.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 11/12/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

public struct TraitContainer {
    let type: TraitContainerType
    let source: Bool
    private(set) var traits: [Trait: TraitInfo]
    
    struct TraitInfo {
        var trait: Trait
        var source: Source
        
        indirect enum Source {
            /// A builtin value has no source
            case builtin
            /// The trait has been explicitly written
            case explicit(TraitReference)
            /// The trait was implied by another trait
            case implied(TraitInfo)
            /// The trait was inherited by a parent function
            case inherited(TraitInfo)
            /// The trait was constrained by a construct happened before the definition
            ///
            /// For a function, this will be the `no capture` trait.
            /// If it is called inside a `match` statement, it will be the `constant` trait
            case implicitlyConstrained(ASTNode, reason: ConstraintReason)
            /// The trait was inferred by a construct inside the definition
            ///
            /// For a function, this may be the `pure` trait.
            case inferred(ASTNode)
        }
        
        enum ConstraintReason {
            case functionUsedBeforeDefinition // -> 'no capture'
            case functionWithSemicolon // -> 'extern'
        }
    }
    
    init(type: TraitContainerType, source: Bool, traits: [TraitInfo], diagnostics: inout [Diagnostic]) {
        self.type = type
        self.source = source
        self.traits = [:]
        for trait in traits {
            if let previous = self.traits[trait.trait] {
                diagnostics.append(Diagnostic(tokens: diagnosticTokens(for: trait.source), message: .duplicateTrait(trait.trait.wrapped.name), severity: .error, hints: [previous.hint].compactMap { $0 }))
            } else {
                self.traits[trait.trait] = trait
            }
        }
        populateImpliedTraits(diagnostics: &diagnostics)
    }
    
    init(type: TraitContainerType, source: Bool, builtin: [Trait]) {
        self.type = type
        self.source = source
        let defaultAccessControl: [Trait] = (source ? [.accessControl(type == .trait ? .open : .public)] : [])
        let traits = (defaultAccessControl + builtin).map { TraitInfo(trait: $0, source: .builtin) }
        self.traits = Dictionary(uniqueKeysWithValues: traits.map { ($0.trait, $0) })
        var diagnostics: [Diagnostic] = []
        populateImpliedTraits(diagnostics: &diagnostics)
        assert(diagnostics.isEmpty)
    }
    
    init(builtinTraitWithTraits traits: [Trait]) {
        self.init(type: .trait, source: true, builtin: traits)
    }
    
    mutating func add(trait: TraitInfo, diagnostics: inout [Diagnostic]) {
        traits[trait.trait] = trait
        implyTraits(for: trait, diagnostics: &diagnostics)
    }
    
    private mutating func populateImpliedTraits(diagnostics: inout [Diagnostic]) {
        for trait in traits.values {
            implyTraits(for: trait, diagnostics: &diagnostics)
        }
    }
    
    private mutating func implyTraits(for trait: TraitInfo, diagnostics: inout [Diagnostic]) {
        if case .builtin = trait.source {
            // assume OK and avoid infinite loop by reinstantiating a TraitContainer recursively
        } else if trait.trait.wrapped.traits.traits[.trait(requiredTraitForType)] == nil {
            switch trait.source {
            case .implied, .inferred, .inherited: // can safely ignore the trait
                traits[trait.trait] = nil
                return
            case .explicit, .builtin, .implicitlyConstrained:
                diagnostics.append(Diagnostic(tokens: diagnosticTokens(for: trait.source), message: .invalidTrait(expected: type, trait: trait), severity: .error))
            }
        }
        for implication in trait.trait.wrapped.implies {
            if traits[implication] == nil {
                add(trait: TraitInfo(trait: implication, source: .implied(trait)), diagnostics: &diagnostics)
            }
        }
        for excluded in trait.trait.wrapped.exclusiveWith {
            if let other = traits[excluded] { // TODO: avoid double diagnostic
                let first, second: TraitInfo
                if case .explicit = other.source,
                   case .implicitlyConstrained = trait.source {
                    (first, second) = (trait, other)
                } else {
                    (first, second) = (other, trait)
                }
                if diagnostics.contains(where: { $0.tokens == diagnosticTokens(for: first.source) }) {
                    continue // already reported
                }
                diagnostics.append(Diagnostic(tokens: diagnosticTokens(for: second.source), message: .incompatibleTraitsProvided(first, second), severity: .error, hints: [first.hint].compactMap { $0 }))
            }
        }
    }
    
    private func diagnosticTokens(for source: TraitInfo.Source) -> [Token] {
        switch source {
        case .builtin:
            fatalError("Invalid traits in builtin")
        case .explicit(let traitReference):
            return traitReference.nodeAllTokens
        case .implied(let traitInfo), .inherited(let traitInfo):
            return diagnosticTokens(for: traitInfo.source)
        case .implicitlyConstrained(let node, _), .inferred(let node):
            return node.nodeAllTokens
        }
    }
    
    private var requiredTraitForType: TraitTrait {
        switch type {
        case .record:
            return .recordTrait
        case .enum:
            return .enumTrait
        case .trait:
            return .traitTrait
        case .func:
            return .funcTrait
        }
    }
}

extension TraitContainer {
    var accessControl: AccessControlTrait {
        for trait in traits.keys {
            if case .accessControl(let result) = trait {
                return result
            }
        }
        // default
        switch type {
        case .trait, .record, .enum, .func:
            return .internal
        }
    }
    
    var callingConvention: CallingConventionTrait {
        for trait in traits.keys {
            if case .callingConvention(let result) = trait {
                return result
            }
        }
        return .suffix
    }
}
