import XCTest
@testable import Natalie

class NatalieTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(Natalie().text, "Hello, World!")
    }


    static var allTests : [(String, (NatalieTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
