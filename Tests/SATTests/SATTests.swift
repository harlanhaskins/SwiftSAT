import XCTest
@testable import SAT

class SATTests: XCTestCase {
    func testTriviallySatisfiable() {
        do {
            let formula = try DIMACSReader().read("""
            p cnf 4 4
            1 0
            2 0
            3 0
            4 0
            """)

            XCTAssert(formula.isSatisfiable())
        } catch {
            XCTFail("\(error)")
        }
    }
}
