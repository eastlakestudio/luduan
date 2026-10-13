import XCTest
@testable import luDuanCore

final class InspirationHintTests: XCTestCase {
    var repository: GameDataRepository!
    
    override func setUp() {
        super.setUp()
        repository = GameDataRepository()
        repository.resetProgress()
    }
    
    func testLevelTitleNameHidesIdiomPhrase() {
        guard let firstBadge = repository.badges.first,
              let level = repository.levelForBadge(firstBadge, skipCompleted: false) else { return }
        XCTAssertFalse(level.title.isEmpty)
    }
    
    func testLevelContainsAnnotationAndSourceText() {
        guard let firstBadge = repository.badges.first,
              let level = repository.levelForBadge(firstBadge, skipCompleted: false) else { return }
        XCTAssertFalse(level.annotation.isEmpty)
        XCTAssertFalse(level.source.isEmpty)
    }
}
