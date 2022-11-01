//
//  CompileCommand.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 21/10/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import ArgumentParser
import SuffixLang

struct PrintASTCommand: ParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(commandName: "parse")
    }
    
    @Argument(help: "The input file to read, as an utf8 encoded suffix source", completion: .file(extensions: ["grph"]))
    var input: String
    
    func run() throws {
        let lexer = Lexer(document: try String(contentsOfFile: input, encoding: .utf8))
        let result = lexer.parseDocument()
        let parser = Parser(tokens: result)
        let nodes = parser.parseAST()
        print(nodes.dumpAST())
        for diagnostic in parser.diagnostics {
            print(diagnostic.representNicely(filepath: input))
        }
        _ = lexer
    }
}
