import XCTest
@testable import luDuanCore

final class DataRepositoryTests: XCTestCase {
    var repository: GameDataRepository!
    
    override func setUp() {
        super.setUp()
        repository = GameDataRepository()
        repository.resetProgress()
    }
    
    func testPresetLevelsAndBadgesLoaded() {
        XCTAssertFalse(repository.levels.isEmpty)
        XCTAssertFalse(repository.badges.isEmpty)
        XCTAssertGreaterThanOrEqual(repository.levels.count, 10)
        XCTAssertGreaterThanOrEqual(repository.badges.count, 200)
    }
    
    func testCompleteLevelUpdatesProgressAndScore() {
        guard let level = repository.levels.first else {
            XCTFail("Missing level preset")
            return
        }
        
        XCTAssertFalse(repository.isLevelCompleted(level.id))
        XCTAssertEqual(repository.userProgress.totalScore, 0)
        
        repository.completeLevel(level)
        
        XCTAssertTrue(repository.isLevelCompleted(level.id))
        XCTAssertGreaterThan(repository.userProgress.totalScore, 0)
    }
    
    func testResetProgress() {
        guard let level = repository.levels.first else { return }
        repository.completeLevel(level)
        
        repository.resetProgress()
        
        XCTAssertEqual(repository.userProgress.totalScore, 0)
        XCTAssertTrue(repository.userProgress.completedLevelIds.isEmpty)
        XCTAssertTrue(repository.userProgress.unlockedBadgeIds.isEmpty)
    }
}
