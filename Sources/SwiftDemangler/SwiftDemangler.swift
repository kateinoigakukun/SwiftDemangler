public struct SwiftDemangler {

    public init() {}
    public func demangle(_ mangledString: String) -> String {
        let parser = Parser(text: mangledString)
        return try! parser.parse().swiftExpression
    }
}
