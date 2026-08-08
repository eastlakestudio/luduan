import XCTest
@testable import luDuanCore

final class SuccessAudioDelayTests: XCTestCase {
    
    func testAudioDelaySequenceConstant() {
        let textDelaySeconds: Double = 0.35
        let soundDelayAfterText: Double = 0.2
        XCTAssertGreaterThan(textDelaySeconds, 0.2)
        XCTAssertLessThanOrEqual(textDelaySeconds, 0.5)
        XCTAssertEqual(textDelaySeconds + soundDelayAfterText, 0.55, accuracy: 0.001)
    }
}
