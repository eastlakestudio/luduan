import XCTest
@testable import luDuanCore

final class AcademicRankFrequencyTests: XCTestCase {
    
    func testAcademicRanksBreakBookLimitsAndTrackFrequencyPhrases() {
        let repository = GameDataRepository()
        repository.resetProgress()
        
        guard let tongShengBadge = repository.badges.first(where: { $0.id == "badge_acad_1_1" }) else {
            XCTFail("应能找到 童生·上 勋章")
            return
        }
        
        let initialProgress = repository.badgeProgressInfo(tongShengBadge)
        XCTAssertEqual(initialProgress.completed, 0)
        XCTAssertEqual(initialProgress.total, 9, "童生·上 应包含 9 个高频启蒙词汇")
        XCTAssertEqual(initialProgress.ratio, 0.0)
        
        // 攻克《史记》名句“破釜沉舟”
        if let poFuLevel = repository.levels.first(where: { $0.targetPhrase == "破釜沉舟" }) {
            repository.completeLevel(poFuLevel)
            let newProgress = repository.badgeProgressInfo(tongShengBadge)
            XCTAssertEqual(newProgress.completed, 1, "攻克《史记》破釜沉舟应能突破书籍限制，增加 童生·上 的进度")
        }
        
        // 攻克《论语》名句“温故知新”
        if let wenGuLevel = repository.levels.first(where: { $0.targetPhrase == "温故知新" }) {
            repository.completeLevel(wenGuLevel)
            let finalProgress = repository.badgeProgressInfo(tongShengBadge)
            XCTAssertEqual(finalProgress.completed, 2, "攻克《论语》温故知新应继续增加 童生·上 的进度")
        }
    }
}
