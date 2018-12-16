import XCTest
@testable import SwiftDemangler

final class SwiftDemanglerTests: XCTestCase {
    func testDemangle(_ mangledString: String, expect: String, file: StaticString = #file, line: UInt = #line) {
        let demangler = SwiftDemangler()
        let demangledString = demangler.demangle(mangledString)

        XCTAssertEqual(demangledString, expect, file: file, line: line)
    }

    func testIsEven() {
        testDemangle(
            "$S13ExampleNumber6isEven6numberSbSi_tF",
            expect: "ExampleNumber.isEven(number: Swift.Int) -> Swift.Bool"
        )
    }
}
