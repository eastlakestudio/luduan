import XCTest
import luDuanCore

final class ShareAndSpeechTests: XCTestCase {

    func testSharePosterCardViewInitialization() {
        guard let firstWord = GameDataRepository.shared.allWords.first else {
            XCTFail("No words loaded")
            return
        }
        let sampleLevel = Classic10000LevelsEngine.levelFromWord(firstWord)
        let posterView = SharePosterCardView(level: sampleLevel, completedCount: 10)
        XCTAssertNotNil(posterView)
    }
}
