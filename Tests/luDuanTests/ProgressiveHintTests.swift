import XCTest
@testable import luDuanCore

final class ProgressiveHintTests: XCTestCase {
    
    func testProgressiveHintCycle() {
        let repo = GameDataRepository.shared
        guard let sampleLevel = repo.levels.first else {
            XCTFail("Levels should not be empty")
            return
        }
        
        let engine = PuzzleEngine(level: sampleLevel)
        XCTAssertEqual(engine.hintStage, 0)
        XCTAssertEqual(engine.selectedIndices.count, 0)
        
        // 第 1 次提示：填入 1 个字
        let count1 = engine.provideHintProgressive()
        XCTAssertEqual(engine.hintStage, 1)
        XCTAssertEqual(count1, 1)
        XCTAssertEqual(engine.selectedIndices.count, 1)
        
        // 第 2 次提示：填入 2 个字
        let count2 = engine.provideHintProgressive()
        XCTAssertEqual(engine.hintStage, 2)
        XCTAssertEqual(count2, 2)
        XCTAssertEqual(engine.selectedIndices.count, 2)
        
        // 第 3 次提示：填入全部正确字
        let count3 = engine.provideHintProgressive()
        XCTAssertEqual(engine.hintStage, 3)
        XCTAssertEqual(count3, sampleLevel.targetPhrase.count)
        XCTAssertEqual(engine.selectedIndices.count, sampleLevel.targetPhrase.count)
        XCTAssertTrue(engine.isCompleted)
    }
}
