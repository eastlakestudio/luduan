import XCTest
@testable import luDuanCore

final class WidgetAndPerformanceTests: XCTestCase {
    
    func testBadgeLevelsPerformance() {
        let repo = GameDataRepository.shared
        guard let firstBadge = repo.badges.first else {
            XCTFail("No badges loaded")
            return
        }
        
        let start = Date()
        let levels = repo.levelsForBadge(firstBadge)
        let elapsed = Date().timeIntervalSince(start)
        
        XCTAssertFalse(levels.isEmpty)
        // Ensure query executes within 0.1s
        XCTAssertLessThan(elapsed, 0.1, "levelsForBadge took too long: \(elapsed)s")
    }
    
    func testAcademicPhrasesSetSpeed() {
        let repo = GameDataRepository.shared
        let academicBadges = repo.badges.filter { $0.category == .academic }
        
        let start = Date()
        for badge in academicBadges {
            _ = repo.academicProgressInfo(badge)
            _ = repo.levelsForBadge(badge)
        }
        let elapsed = Date().timeIntervalSince(start)
        
        // Iterating over all academic badges should be nearly instantaneous (< 0.2s)
        XCTAssertLessThan(elapsed, 0.2, "Academic badges processing took too long: \(elapsed)s")
    }
}
