import XCTest
@testable import HornedFoxCore

final class ThemeProgressionTests: XCTestCase {
    var repository: GameDataRepository!
    
    override func setUp() {
        super.setUp()
        repository = GameDataRepository()
        repository.resetProgress()
    }
    
    func testNextUncompletedLevelFindsFirstUncompletedLevelInTheme() {
        let shihanLevels = repository.levels.filter { $0.theme == .shihan }
        XCTAssertFalse(shihanLevels.isEmpty)
        
        let nextLevel = repository.nextUncompletedLevel(for: .shihan)
        XCTAssertEqual(nextLevel?.id, shihanLevels[0].id)
        
        repository.completeLevel(shihanLevels[0])
        
        let nextLevelAfterComplete = repository.nextUncompletedLevel(for: .shihan)
        XCTAssertEqual(nextLevelAfterComplete?.id, shihanLevels[1].id)
    }
    
    func testNextLevelSequentialProgression() {
        guard let first = repository.levels.first else { return }
        let next = repository.nextLevel(after: first)
        XCTAssertNotNil(next)
        XCTAssertEqual(next?.id, repository.levels[1].id)
    }
    
    func testSetActiveThemeUpdatesUserProgress() {
        XCTAssertEqual(repository.userProgress.lastActiveTheme, .shihan)
        repository.setActiveTheme(.shijing)
        XCTAssertEqual(repository.userProgress.lastActiveTheme, .shijing)
    }
}
