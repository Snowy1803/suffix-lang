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

struct TraitContainer {
    var type: TraitContainerType
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
            case implicitlyConstrained(ASTNode)
            /// The trait was inferred by a construct inside the definition
            ///
            /// For a function, this may be the `pure` trait.
            case inferred(ASTNode)
        }
    }
    
    init(type: TraitContainerType, traits: [TraitInfo], diagnostics: inout [Diagnostic]) {
        self.type = type
        self.traits = Dictionary(uniqueKeysWithValues: traits.map { ($0.trait, $0) })
        populateImpliedTraits(diagnostics: &diagnostics)
    }
    
    init(type: TraitContainerType, builtin: [Trait]) {
        self.type = type
        let traits = ([.accessControl(type == .trait ? .open : .public)] + builtin).map { TraitInfo(trait: $0, source: .builtin) }
        self.traits = Dictionary(uniqueKeysWithValues: traits.map { ($0.trait, $0) })
        var diagnostics: [Diagnostic] = []
        populateImpliedTraits(diagnostics: &diagnostics)
        assert(diagnostics.isEmpty)
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
            if let other = traits[excluded] {
                diagnostics.append(Diagnostic(tokens: diagnosticTokens(for: trait.source), message: .incompatibleTraitsProvided(trait, other), severity: .error, hints: [Diagnostic(tokens: diagnosticTokens(for: other.source), message: .incompatibleTraitsProvided(trait, other), severity: .error)]))
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
        case .implicitlyConstrained(let node), .inferred(let node):
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
