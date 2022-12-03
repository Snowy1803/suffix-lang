//
//  TypeChecker.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 05/11/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuffixLang

public class TypeChecker {
    var builtinContext = BuiltinParsingContext.shared
    var rootContext: RootParsingContext!
    var rootBlock: BlockContent
    public var passes: [TypeCheckingPass] = [
        ClosurePass(),
        DeadCodePass(),
    ]
    public var verbose = false
    
    // output
    /// The diagnostics generated by this type checker
    public internal(set) var diagnostics: [Diagnostic] = []
    /// The functions that were found. Includes named, anonymous and synthesized functions, but not builtins
    public internal(set) var functions: [Function] = []
    
    public init(rootBlock: BlockContent) {
        self.rootBlock = rootBlock
        self.rootContext = RootParsingContext(typechecker: self, builtins: builtinContext)
    }
    
    func checkPasses() {
        if !(passes.first is ClosurePass) {
            print("warning: invalid passes: expected closure resolution to be the first pass")
        }
    }
    
    public func typecheck() {
        checkPasses()
        if verbose {
            print("Starting build")
        }
        rootBlock.typecheckContent(context: rootContext)
        for pass in passes {
            guard !diagnostics.contains(where: { $0.severity >= .error }) else {
                print("Skipping remaining passes because of errors")
                break
            }
            if verbose {
                print("Running pass: \(pass)")
            }
            pass.run(typechecker: self)
        }
    }
    
    func prepareSuffilForPrinting() {
        for function in functions {
            function.prepareSuffilForPrinting()
        }
    }
    
    public func getSuffil() -> String {
        prepareSuffilForPrinting()
        return functions.map(\.description).joined(separator: "\n")
    }
}
