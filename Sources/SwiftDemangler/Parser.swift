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

    var currentOrNil: Character? {
        guard text.indices.contains(currentPosition) else {
            return nil
        }
        return text[currentPosition]
    }

    init(text: String) {
        self.text = text
        self.currentPosition = text.startIndex
    }

    func parse() throws -> Node.Global {
        try parsePrefix()
        if isFunction() {
            return Node.Global(node: parseFunction())
        }
        fatalError()
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

    func isFunction() -> Bool {
        return text.last == "F"
    }

    func parsePrefix() throws {
        switch current {
        case "$" where peek() == "S":
            skip(by: 2)
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
        case "y":
            skip(by: 1)
            return .list([])
        default:
            fatalError()
        }
    }

    func parseFunction() -> Node {
        let module = Node.Module(text: parseIdentifier().text)
        let functionName = parseIdentifier()
        var arguments = [Node.Identifier]()
        while current != "S" {
            arguments.append(parseIdentifier())
        }

        let sign = parseFunctionSign()
        return Node.function(module, functionName, arguments, sign)
    }

    func parseFunctionSign() -> Node.Function {
        let returnType = parseType()
        let argumentTuple = parseType().list!
        let throwsAnnotation = currentOrNil == "K"
        return Node.Function(
            returnType: returnType, argumentTuple: argumentTuple,
            throwsAnnotation: throwsAnnotation
        )
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
