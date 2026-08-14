import XCTest
@testable import luDuanCore

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
    
    /// 测试 SpeechRecognitionManager 多线程安全调用与状态重置
    func testSpeechRecognitionManagerThreadSafety() {
        let manager = SpeechRecognitionManager.shared
        let expectation = self.expectation(description: "SpeechRecognitionCompletion")
        
        // 从后台异步线程并发安全调用 start/stop/toggle
        DispatchQueue.global(qos: .userInitiated).async {
            manager.startRecording(simulatedText: "知行合一") { recognized in
                XCTAssertEqual(recognized, "知行合一")
            }
            
            // 子线程安全调用 stopRecording
            manager.stopRecording()
            
            DispatchQueue.main.async {
                XCTAssertFalse(manager.isRecording)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 2.0, handler: nil)
    }
}
