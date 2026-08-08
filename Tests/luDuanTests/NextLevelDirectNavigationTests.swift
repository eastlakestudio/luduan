import XCTest
@testable import luDuanCore

final class NextLevelDirectNavigationTests: XCTestCase {
    
    func testNextLevelDirectLoadingSequence() {
        let repo = GameDataRepository()
        let level1 = repo.levels[0]
        let level2 = repo.levels[1]
        
        let engine = PuzzleEngine(level: level1)
        XCTAssertEqual(engine.level.id, level1.id)
        
        // 模拟直接加载下一个关卡 (level2)
        engine.resetForNewLevel(level2)
        XCTAssertEqual(engine.level.id, level2.id)
        XCTAssertEqual(engine.selectedIndices.count, 0)
        XCTAssertFalse(engine.isCompleted)
    }
}
