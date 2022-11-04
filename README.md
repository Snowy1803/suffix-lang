# The Suffix Programming Language

A type-safe functional programming language using Reverse Polish Notation.

## Concepts

A Suffix program is made of top-level instructions. The two most important instructions are `&` (push) and `.` (call): `&2 &3 .+` calls the `+` function with arguments `2` and `3`. Suffix uses RPN, so it has a stack you can push values to. Functions take a certain amount of stack elements, and push new ones instead.

Contrary to most RPN languages, Suffix is type-safe: all function declare how much values they take, their type, and what they return. As such, the value stack only exists at compilation.

There are no variables and no loops, only constants (called bindings) and recursion.

Identifiers can contain many characters, including spaces. Types and values are in a different name space.

The different instructions are:
 - `&` push a value to the stack
 - `.` call a function by name
 - `>` pop a value and bind it a name: `&2 > two` means `two` now refers to the value `2`
 - `func` declare a function
 - `record` declare a record (an immutable data structure)

## Driver

To run the driver, build the `suffix` command line tool with `swift build --product suffix`.

The different commands are:
 - `suffix lex <file.suffix>`: Prints a debug list of tokens from the lexer
 - `suffix parse <file.suffix>`: Prints a debug AST view from the parser
 - more to come...

## Targets

 - `SuffixLang` contains the lexer, the parser, and the AST structs
 - `Sema` (Coming Soon) contains the type checker
 - `IRGen` (Coming Soon) contains the LLVM IR code generator
 - `Driver` contains the command line tool
 - `LSP` (Coming Soon) contains the LSP server for integration with IDEs
