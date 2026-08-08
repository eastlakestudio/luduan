import XCTest
@testable import HornedFoxCore

final class SkipLevelTests: XCTestCase {
    
    func testSkipLevelCompletesCurrentAndAdvancesToNext() {
        let repository = GameDataRepository()
        repository.resetProgress()
        
        guard let level1 = repository.levels.first else {
            XCTFail("Levels should not be empty")
            return
        }
        
        XCTAssertFalse(repository.isLevelCompleted(level1.id))
        
        // 执行跳关逻辑
        repository.completeLevel(level1)
        XCTAssertTrue(repository.isLevelCompleted(level1.id))
        
        let nextLevel = repository.nextLevel(after: level1)
        XCTAssertNotNil(nextLevel)
        XCTAssertEqual(nextLevel?.id, repository.levels[1].id)
    }
    
    func testLuduanBrandStrings() {
        XCTAssertEqual(ThemeDimension.academic.rawValue, "学阶功名")
        XCTAssertEqual(ThemeDimension.classics.rawValue, "典籍名篇")
        XCTAssertEqual(ThemeDimension.practical.rawValue, "处世修养")
    }
}
