//
//  ParserTests.swift
//  SwiftDemanglerTests
//
//  Created by Yuta Saito on 2018/12/16.
//

import XCTest
@testable import SwiftDemangler

class ParserTests: XCTestCase {

    func testParse(_ mangledString: String, expect: Node, file: StaticString = #file, line: UInt = #line) {
        let parser = Parser(text: mangledString)
        do {
            let global = try parser.parse()
            XCTAssertEqual(global.node, expect, file: file, line: line)
        } catch {
            XCTFail(String.init(describing: error), file: file, line: line)
        }
    }

    func testIsEven() {
        testParse(
            "$S13ExampleNumber6isEven6numberSbSi_tF",
            expect: .function(
                .init(text: "ExampleNumber"), .init(text: "isEven"),
                [.init(text: "number")],
                Node.Function(
                    returnType: .shortenType(.bool),
                    argumentTuple: ([.shortenType(.int)]), throwsAnnotation: false
                )
            )
        )
    }

    func testParseIdentifier() {
        let parser = Parser(text: "4hoge")
        let idLength = parser.parseInt()
        XCTAssertEqual(parser.parseIdentifier(length: idLength).text, "hoge")
    }

    func testParseModule() throws {
        let parser = Parser(text: "$S13ExampleNumber6isEven6numberSbSi_tF")
        let global = try parser.parse()
        guard let module = global.module else { XCTFail(); return }
        XCTAssertEqual(module.text, "ExampleNumber")
    }

    func testParseType() {
        do {
            let parser = Parser(text: "Si")
            XCTAssertEqual(parser.parseType(), .shortenType(.int))
        }
        do {
            let parser = Parser(text: "Si_Sbt")
            XCTAssertEqual(parser.parseType(), .list([.shortenType(.int), .shortenType(.bool)]))
        }
    }

    func testParseFuncion() {
        let parser = Parser(text: "SbSi_t")
        XCTAssertEqual(parser.parseFunctionSign(), Node.Function(returnType: .shortenType(.bool), argumentTuple: [.shortenType(.int)], throwsAnnotation: false))
    }

    func testParseThrowableFunction() {
        let parser = Parser(text: "SbSi_tK")
        XCTAssertEqual(parser.parseFunctionSign(), .init(returnType: .shortenType(.bool), argumentTuple: [.shortenType(.int)], throwsAnnotation: true))
    }
}
