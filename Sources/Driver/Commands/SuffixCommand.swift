//
//  main.swift
//  SuffixLang
// 
//  Created by Emil Pedersen on 21/10/2022.
//  Copyright © 2022 Emil Pedersen (emil.codes). All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import ArgumentParser

@main
struct SuffixCommand: ParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "suffix",
            abstract: "Run operations on Suffix code",
            subcommands: [PrintLexemesCommand.self, PrintASTCommand.self, CheckCommand.self]
        )
    }
}
