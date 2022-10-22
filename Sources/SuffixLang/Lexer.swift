//
//  Lexer.swift
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

public class Lexer {
    var document: String
    var result: [Token] = []
    
    // State
    var start: TokenPosition
    var position: TokenPosition
    var type: TokenType
    var isEscaped: Bool = false
    
    public init(document: String) {
        self.document = document
        start = TokenPosition(index: document.startIndex)
        position = start
        type = .unresolved
    }
    
    func handleCharacter() -> Satisfaction {
        let char = document[position.index]
        switch type {
        case .whitespace:
            return char.isWhitespace ? .satisfies : .newToken
        case .comment:
            return char.isNewline ? .satisfiesAndTerminates : .satisfies
        case .identifier:
            return char.isLetter || char.isNumber || char.isWhitespace || "_/%*+-".contains(char) ? .satisfies : .newToken
        case .integerLiteral:
            return char.isNumber || char.isWhitespace || char == "_" ? .satisfies : .newToken
        case .stringLiteral:
            if isEscaped {
                isEscaped = false
                return .satisfies
            }
            if char == "\\" {
                isEscaped = true
                return .satisfies
            }
            if char == "\"" {
                return .satisfiesAndTerminates
            }
            return .satisfies
        case .typingOperator:
            if char == ":" {
                type = .coercingOperator
                return .satisfies
            }
            return .newToken
        case .dotOperator:
            if char == "." {
                type = .twoDots
                return .satisfies
            }
            return .newToken
        case .twoDots:
            if char == "." {
                type = .variadic
                return .satisfies
            }
            return .newToken
        case .pushOperator, .bindOperator, .coercingOperator, .variadic, .curlyOpen, .curlyClose, .parenOpen, .parenClose, .comma, .unresolved:
            return .newToken
        case .floatLiteral, .keyword:
            print("shouldn't happen")
            return .newToken
        }
    }
    
    func newTokenType() -> TokenType {
        let char = document[position.index]
        if char.isWhitespace {
            return .whitespace
        }
        if char.isNumber {
            return .integerLiteral
        }
        if char.isLetter || "_/%*+-".contains(char) {
            return .identifier
        }
        switch char {
        case "#":
            return .comment
        case "\"":
            return .stringLiteral
        case ".":
            return .dotOperator
        case "&":
            return .pushOperator
        case ">":
            return .bindOperator
        case ":":
            return .typingOperator
        case "{":
            return .curlyOpen
        case "}":
            return .curlyClose
        case "(":
            return .parenOpen
        case ")":
            return .parenClose
        case ",":
            return .comma
        default:
            return .unresolved
        }
    }
    
    func parseStringLiteral(token: Token) -> [Token.StringComponent] {
        var result: [Token.StringComponent] = []
        let literal = token.literal.dropFirst().dropLast(token.literal.hasSuffix("\"") ? 1 : 0)
        var iterator = literal.indices.makeIterator()
        var current: Token.StringComponent?
        func commit(_ i: String.Index, include: Bool) {
            if var current {
                if include {
                    current.substring = literal[current.substring.startIndex...i]
                } else {
                    current.substring = literal[current.substring.startIndex..<i]
                }
                result.append(current)
            }
            current = nil
        }
        while let i = iterator.next() {
            if literal[i] == "\\", let next = iterator.next() {
                commit(i, include: false)
                result.append(.escaped(literal[i...next]))
            } else if literal[i] == "%" {
                commit(i, include: false)
                current = .percent(literal[i...i])
            } else if case .percent(_) = current, literal[i].isLetter {
                commit(i, include: true)
            } else if current == nil {
                current = .literal(literal[i...i])
            }
        }
        commit(literal.endIndex, include: false)
        return result
    }
    
    func didAddToken() {
        // resolves literals
        do {
            let literal = Array(result.suffix(3))
            if literal.count == 3,
               literal[0].type == .integerLiteral,
               literal[1].type == .dotOperator,
               literal[2].type == .integerLiteral {
                result.removeLast(3)
                result.append(Token(
                    position: literal[0].position,
                    literal: document[literal[0].literal.startIndex..<literal[2].literal.endIndex],
                    type: .floatLiteral))
            }
            if var last = result.last {
                defer { result[result.endIndex - 1] = last }
                switch type {
                case .integerLiteral:
                    last.data = .int(Int(last.literal.filter({ $0.isNumber })) ?? 0)
                case .floatLiteral:
                    last.data = .float(Double(last.literal.filter({ $0.isNumber || $0 == "." })) ?? 0)
                case .identifier:
                    let source = last.literal
                    var result = ""
                    var isSpaced = false
                    for char in source {
                        if char.isWhitespace {
                            isSpaced = true
                            continue
                        }
                        if isSpaced {
                            result.append(" ")
                            isSpaced = false
                        }
                        result.append(char)
                    }
                    last.data = .identifier(result)
                case .stringLiteral:
                    last.data = .interpolation(parseStringLiteral(token: last))
                default:
                    break
                }
            }
            if let last = result.last,
               last.type == .identifier,
               case .identifier(let id) = last.data {
                let words = id.split(separator: " ")
                if let keyword = words.first,
                   keyword == "func" || keyword == "record" {
                    result.removeLast()
                    var pos = last.position
                    pos.advance(by: keyword.count, in: document)
                    result.append(Token(position: last.position, literal: document[last.position.index..<pos.index], type: .keyword))
                    let whitespaceStart = pos
                    while document[pos.index].isWhitespace {
                        pos.nextChar(document: document)
                    }
                    result.append(Token(position: whitespaceStart, literal: document[whitespaceStart.index..<pos.index], type: .whitespace))
                    if pos.index != last.literal.endIndex {
                        result.append(Token(position: pos, literal: document[pos.index..<last.literal.endIndex], type: .identifier, data: .identifier(String(id.dropFirst(keyword.count + 1)))))
                    }
                }
            }
        }
    }
    
    func commitPreviousIfNeeded() {
        if start.index != position.index {
            result.append(Token(position: start, literal: document[start.index..<position.index], type: type))
            didAddToken()
        }
    }
    
    public func nextCharacter() {
        let satisfaction = handleCharacter()
        switch satisfaction {
        case .satisfies:
            break
        case .newToken:
            commitPreviousIfNeeded()
            start = position
            type = newTokenType()
        case .satisfiesAndTerminates:
            result.append(Token(position: start, literal: document[start.index...position.index], type: type))
            didAddToken()
            type = .unresolved
            start = position
            start.nextChar(document: document)
        }
        position.nextChar(document: document)
    }
    
    public func parseDocument() -> [Token] {
        while position.index != document.endIndex {
            nextCharacter()
        }
        commitPreviousIfNeeded()
        return result
    }
    
    enum Satisfaction {
        case satisfies
        case newToken
        case satisfiesAndTerminates
    }
}
