import XCTest
@testable import luDuanCore

final class ProgressiveHintTests: XCTestCase {
    
    func testInstantFullHintFillsAllCharactersAndCompletes() {
        let repo = GameDataRepository.shared
        guard let sampleLevel = repo.allWords.first.map({ Classic10000LevelsEngine.levelFromWord($0) }) else {
            XCTFail("Levels should not be empty")
            return
        }
        
        let engine = PuzzleEngine(level: sampleLevel)
        XCTAssertEqual(engine.selectedIndices.count, 0)
        XCTAssertFalse(engine.isCompleted)
        
        // 灵感一键全量提示：一次性填入整句所有正确字并达成通关
        let count = engine.provideAllHints()
        XCTAssertEqual(count, sampleLevel.targetPhrase.count)
        XCTAssertEqual(engine.selectedIndices.count, sampleLevel.targetPhrase.count)
        XCTAssertTrue(engine.isCompleted)
    }
}
