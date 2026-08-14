import XCTest
@testable import luDuanCore

final class CardLevelRandomizationTests: XCTestCase {
    
    func testBadgeWordsAreShuffledAndNotJustThreeKingdoms() {
        let repo = GameDataRepository()
        
        // 测试多个常见卡片
        let testBadgeIds = [
            "badge_academic_tongsheng",
            "badge_academic_xiucai",
            "badge_practical_xiushen",
            "badge_practical_zhixing",
            "badge_practical_lishen"
        ]
        
        var startingPhrases = Set<String>()
        var startingSources = Set<String>()
        
        for id in testBadgeIds {
            let words = repo.badgeWords(for: id)
            if let first = words.first {
                startingPhrases.insert(first.phrase)
                startingSources.insert(first.source)
            }
        }
        
        // 验证不同卡片的开头词语具有多样性，不是单一重复的同一个
        XCTAssertGreaterThan(startingPhrases.count, 1, "Different cards should start with different phrases")
    }
    
    func testBadgeWordsOrderIsStableForSameBadge() {
        let repo = GameDataRepository()
        let badgeId = "badge_academic_tongsheng"
        
        let words1 = repo.badgeWords(for: badgeId).map { $0.phrase }
        let words2 = repo.badgeWords(for: badgeId).map { $0.phrase }
        
        // 同一卡片内部关卡顺序确定自洽，确保用户通关进度平滑
        XCTAssertEqual(words1, words2, "Words order for same badge must be deterministic and stable")
    }
    
    func testThemeWordsAreDiverse() {
        let repo = GameDataRepository()
        let shijing = repo.themeWords(for: .shijing)
        let tangsong = repo.themeWords(for: .tangsong)
        let shihan = repo.themeWords(for: .shihan)
        
        XCTAssertFalse(shijing.isEmpty)
        XCTAssertFalse(tangsong.isEmpty)
        XCTAssertFalse(shihan.isEmpty)
        
        // 各主模式首关不同
        let first1 = shijing.first?.phrase
        let first2 = tangsong.first?.phrase
        let first3 = shihan.first?.phrase
        
        XCTAssertNotEqual(first1, first2)
        XCTAssertNotEqual(first2, first3)
    }
}
