import XCTest
@testable import HornedFoxCore

final class RootLaunchNavigationTests: XCTestCase {
    
    func testRepositoryThemeProgress() {
        let repo = GameDataRepository.shared
        XCTAssertGreaterThan(repo.levels.count, 0)
        
        let sampleLevel = repo.levels[0]
        let progress = repo.themeProgressInfo(for: sampleLevel)
        XCTAssertGreaterThan(progress.totalCount, 0)
        XCTAssertGreaterThanOrEqual(progress.currentIndex, 1)
    }
}
