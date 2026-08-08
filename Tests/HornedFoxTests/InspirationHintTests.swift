import XCTest
@testable import HornedFoxCore

final class InspirationHintTests: XCTestCase {
    var repository: GameDataRepository!
    
    override func setUp() {
        super.setUp()
        repository = GameDataRepository()
        repository.resetProgress()
    }
    
    func testLevelTitleNameHidesIdiomPhrase() {
        guard let level = repository.levels.first else { return }
        let titleName = repository.levelTitleName(for: level)
        XCTAssertEqual(titleName, level.title)
    }
    
    func testLevelContainsAnnotationAndSourceText() {
        guard let level = repository.levels.first else { return }
        XCTAssertFalse(level.annotation.isEmpty)
        XCTAssertFalse(level.source.isEmpty)
    }
}
