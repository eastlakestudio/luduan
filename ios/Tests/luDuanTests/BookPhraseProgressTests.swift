import XCTest
@testable import luDuanCore

final class BookPhraseProgressTests: XCTestCase {
    
    func testBookPhrasesMappingAndDeduplicatedProgress() {
        let repository = GameDataRepository()
        repository.resetProgress()
        
        let shijingPhrases = repository.uniquePhrases(forBook: "shijing")
        XCTAssertGreaterThan(shijingPhrases.count, 0, "《诗经》去重词汇数应大于0")
        
        let initialProgress = repository.bookProgressInfo(forBook: "shijing")
        XCTAssertEqual(initialProgress.completed, 0)
        XCTAssertEqual(initialProgress.total, shijingPhrases.count)
        XCTAssertEqual(initialProgress.ratio, 0.0)
        
        // 模拟完成第一关关卡（包含“关关雎鸠”）
        if let firstLevel = repository.levels.first {
            repository.completeLevel(firstLevel)
            
            let newProgress = repository.bookProgressInfo(forBook: "shijing")
            XCTAssertGreaterThanOrEqual(newProgress.completed, 1, "完成关卡后《诗经》已完成词语数应增加")
            XCTAssertGreaterThan(newProgress.ratio, 0.0)
            XCTAssertLessThanOrEqual(newProgress.ratio, 1.0)
        }
    }
    
    func testBadgeProgressInfoDeduplication() {
        let repository = GameDataRepository()
        repository.resetProgress()
        
        if let shijingBadge = repository.badges.first(where: { $0.id == "badge_shijing" }) {
            let initialBadgeProgress = repository.badgeProgressInfo(shijingBadge)
            XCTAssertEqual(initialBadgeProgress.completed, 0)
            
            if let firstLevel = repository.levels.first {
                repository.completeLevel(firstLevel)
                let newBadgeProgress = repository.badgeProgressInfo(shijingBadge)
                XCTAssertGreaterThanOrEqual(newBadgeProgress.completed, 1)
            }
        }
    }
}
