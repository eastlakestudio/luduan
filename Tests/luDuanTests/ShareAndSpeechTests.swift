import XCTest
import luDuanCore

final class ShareAndSpeechTests: XCTestCase {
    
    func testSpeechRecognitionManagerSingletonAndAuthorization() {
        let manager = SpeechRecognitionManager.shared
        XCTAssertFalse(manager.isRecording, "初始化状态下不应处于录音状态")
    }
    
    func testSharePosterCardViewInitialization() {
        let sampleLevel = Classic10000LevelsEngine.level(at: 0)
        XCTAssertEqual(sampleLevel.targetPhrase, "关关雎鸠")
        
        let posterView = SharePosterCardView(level: sampleLevel, completedCount: 10)
        XCTAssertNotNil(posterView)
    }
}
