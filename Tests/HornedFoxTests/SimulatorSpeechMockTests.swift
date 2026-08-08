import XCTest
@testable import HornedFoxCore

final class SimulatorSpeechMockTests: XCTestCase {
    
    func testSimulatorSpeechMockEmission() {
        let manager = SpeechRecognitionManager()
        XCTAssertFalse(manager.isRecording)
        
        manager.startRecording(simulatedText: "破釜沉舟") { text in
            XCTAssertEqual(text, "破釜沉舟")
        }
        XCTAssertTrue(manager.isRecording)
    }
}
