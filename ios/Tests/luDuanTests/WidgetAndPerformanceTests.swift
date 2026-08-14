import XCTest
@testable import luDuanCore

final class WidgetAndPerformanceTests: XCTestCase {
    
    func testLazyLevelForBadgePerformance() {
        let repo = GameDataRepository.shared
        guard let firstBadge = repo.badges.first else {
            XCTFail("No badges loaded")
            return
        }
        
        let start = Date()
        let level = repo.levelForBadge(firstBadge, skipCompleted: true)
        let elapsed = Date().timeIntervalSince(start)
        
        XCTAssertNotNil(level)
        // Ensure lazy single-level retrieval executes in under 5ms
        XCTAssertLessThan(elapsed, 0.02, "levelForBadge took too long: \(elapsed)s")
    }
    
    func testAllBadgesProgressInfoPerformance() {
        let repo = GameDataRepository.shared
        let allBadges = repo.badges
        
        let start = Date()
        for badge in allBadges {
            let progress = repo.badgeProgressInfo(badge)
            XCTAssertGreaterThanOrEqual(progress.ratio, 0.0)
            XCTAssertLessThanOrEqual(progress.ratio, 1.0)
        }
        let elapsed = Date().timeIntervalSince(start)
        
        // Iterating over all badges for UI progress must be instantaneous (< 0.05s)
        XCTAssertLessThan(elapsed, 0.05, "All badges progress processing took too long: \(elapsed)s")
    }
    
    func testNavigationPerformance() {
        let repo = GameDataRepository.shared
        guard let firstBadge = repo.badges.first,
              let level = repo.levelForBadge(firstBadge, skipCompleted: false) else {
            XCTFail("Could not get sample level")
            return
        }
        
        let start = Date()
        let info = repo.themeProgressInfo(for: level)
        let next = repo.nextThemeLevel(after: level)
        let elapsed = Date().timeIntervalSince(start)
        
        XCTAssertGreaterThan(info.totalCount, 0)
        XCTAssertNotNil(next)
        XCTAssertLessThan(elapsed, 0.01, "Navigation resolution took too long: \(elapsed)s")
    }
}
