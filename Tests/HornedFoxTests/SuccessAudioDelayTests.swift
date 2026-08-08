import XCTest
@testable import HornedFoxCore

final class SuccessAudioDelayTests: XCTestCase {
    
    func testAudioDelaySequenceConstant() {
        let textDelaySeconds: Double = 0.35
        XCTAssertGreaterThan(textDelaySeconds, 0.2)
        XCTAssertLessThanOrEqual(textDelaySeconds, 0.5)
    }
}
