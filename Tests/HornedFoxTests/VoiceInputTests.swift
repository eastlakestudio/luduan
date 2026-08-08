import XCTest
@testable import HornedFoxCore

final class VoiceInputTests: XCTestCase {
    
    func testVoiceInputMatchingTargetPhrase() {
        let sampleLevel = LevelModel(
            id: "voice_test_01",
            theme: .shihan,
            title: "野火烧不尽",
            targetPhrase: "野火烧不尽",
            tileMatrix: ["野", "火", "烧", "不", "尽", "春", "风", "吹"],
            annotation: "测试",
            story: "测试",
            source: "《古诗》"
        )
        
        let engine = PuzzleEngine(level: sampleLevel)
        XCTAssertEqual(engine.selectedIndices.count, 0)
        
        // 模拟语音识别输出字符串 "野火烧不尽！"
        let matchedCount = engine.processVoiceInputString("野火烧不尽！")
        XCTAssertEqual(matchedCount, 5)
        XCTAssertEqual(engine.selectedIndices.count, 5)
        XCTAssertEqual(engine.currentInput, "野火烧不尽")
        XCTAssertTrue(engine.isCompleted)
    }
}
