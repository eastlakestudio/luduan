import XCTest
@testable import luDuanCore

final class RootLaunchNavigationTests: XCTestCase {
    
    func testRepositoryThemeProgress() {
        let repo = GameDataRepository.shared
        XCTAssertGreaterThan(repo.allWords.count, 0)
        
        guard let sampleLevel = repo.allWords.first.map({ Classic10000LevelsEngine.levelFromWord($0) }) else {
            XCTFail("Missing sample level")
            return
        }
        let progress = repo.themeProgressInfo(for: sampleLevel)
        XCTAssertGreaterThan(progress.totalCount, 0)
        XCTAssertGreaterThanOrEqual(progress.currentIndex, 1)
    }
}
