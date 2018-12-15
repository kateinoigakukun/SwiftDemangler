import XCTest

extension SwiftDemanglerTests {
    static let __allTests = [
        ("testIsEven", testIsEven),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SwiftDemanglerTests.__allTests),
    ]
}
#endif
