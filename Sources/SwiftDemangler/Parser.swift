//
//  Parser.swift
//  SwiftDemangler
//
//  Created by Yuta Saito on 2018/12/16.
//

import Foundation

class Parser {

    typealias Position = String.Index
    var currentPosition: Position
    let text: String
    var current: Character {
        return text[currentPosition]
    }

    init(text: String) {
        self.text = text
        self.currentPosition = text.startIndex
    }

    func parse() throws -> Node.Global {
        try parsePrefix()
        return Node.Global(
            node: .function(
                Node.Module(text: parseIdentifier().text),
                parseIdentifier(),
                [parseIdentifier()],
                Node.Function(returnType: parseType(), argumentTuple: parseType())
            )
        )
    }

    func next() -> Character {
        currentPosition = text.index(after: currentPosition)
        return current
    }

    func peek() -> Character? {
        guard text.indices.contains(text.index(after: currentPosition)) else {
            return nil
        }
        return text[text.index(after: currentPosition)]
    }

    func parsePrefix() throws {
        switch current {
        case "$" where peek() == "S":
            _ = next()
            _ = next()
            return
        default:
             throw Error.unsupportedPrefix
        }
    }

    func parseInt() -> Int {
        assert(current.isDigit)
        var digitChars = [current]
        while next().isDigit {
            digitChars.append(current)
        }
        return Int(String(digitChars))!
    }

    func skip(by length: Int) {
        currentPosition = text.index(currentPosition, offsetBy: length)
    }

    func parseIdentifier(length: Int) -> Node.Identifier {
        let endIndex = text.index(currentPosition, offsetBy: length)
        let identifier = String(text[currentPosition..<endIndex])
        skip(by: length)
        return .init(text: identifier)
    }

    func parseIdentifier() -> Node.Identifier {
        let length = parseInt()
        return parseIdentifier(length: length)
    }

    func parseType() -> Type {
        switch current {
        case "S":
            guard let shortenType = Type.ShortenType(rawValue: String(["S", next()])) else {
                fallthrough
            }

            if peek() == "_" {
                skip(by: 2)
                var types = [Type.shortenType(shortenType)]
                while current != "t" {
                    types.append(parseType())
                }
                skip(by: 1)
                return .list(types)
            }
            skip(by: 1)
            return .shortenType(shortenType)
        default:
            fatalError()
        }
    }

    func parseFunction() -> Node.Function {
        return Node.Function(returnType: parseType(), argumentTuple: parseType())
    }

    enum Error: Swift.Error {
        case unsupportedPrefix
    }
}

extension Character {
    var isDigit: Bool {
        return CharacterSet.decimalDigits.contains(unicodeScalars.first!)
    }
}