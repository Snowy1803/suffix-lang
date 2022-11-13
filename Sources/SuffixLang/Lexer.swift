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
    static let keywords: [String: KeywordType] = [
        "func": .func,
        "record": .record,
        "enum": .enum,
        "typealias": .typealias,
//        "where": .whereKeyword, // this would actually be contextual
    ]
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
        case .pushOperator, .bindOperator, .coercingOperator, .variadic, .curlyOpen, .curlyClose, .parenOpen, .parenClose, .bracketOpen, .bracketClose, .comma, .unresolved:
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
        case "[":
            return .bracketOpen
        case "]":
            return .bracketClose
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
                switch last.type {
                case .integerLiteral:
                    last.data = .int(Int(last.literal.filter({ $0.isNumber })) ?? 0)
                case .floatLiteral:
                    last.data = .float(Double(last.literal.filter({ $0.isNumber || $0 == "." })) ?? 0)
                case .stringLiteral:
                    last.data = .interpolation(parseStringLiteral(token: last))
                default:
                    break
                }
            }
            if let last = result.last,
               last.type == .identifier {
                let source = last.literal
                var words: [Substring] = []
                var current: Substring = source[source.startIndex..<source.startIndex]
                var isSpaced = false
                for (index, char) in zip(source.indices, source) {
                    if char.isWhitespace {
                        isSpaced = true
                        continue
                    }
                    if isSpaced {
                        words.append(current)
                        current = source[index...index]
                        isSpaced = false
                    }
                    current = source[current.startIndex...index]
                }
                words.append(current)
                var start = 0
                var pos = last.position
                result.removeLast()
                func commit(_ i: Int) {
                    if i != start {
                        let end = i == words.count ? last.literal.endIndex : words[i].startIndex
                        let firstWord = words[start]
                        pos.advance(to: firstWord.startIndex, in: document)
                        result.append(
                            Token(position: pos,
                                  literal: document[firstWord.startIndex..<end],
                                  type: .identifier,
                                  data: .identifier(words[start..<i].joined(separator: " "))))
                    }
                }
                for (i, word) in words.enumerated() {
                    if let keywordType = Self.keywords[String(word)] {
                        commit(i)
                        pos.advance(to: word.startIndex, in: document)
                        result.append(Token(position: pos, literal: word, type: .keyword(keywordType)))
                        start = i + 1
                        let end = start == words.count ? last.literal.endIndex : words[start].startIndex
                        if word.endIndex != end {
                            pos.advance(to: word.endIndex, in: document)
                            result.append(Token(position: pos, literal: document[word.endIndex..<end], type: .whitespace))
                        }
                    }
                }
                commit(words.count)
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
