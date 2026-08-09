import XCTest
import luDuanCore

final class ThemeFilteringTests: XCTestCase {
    
    func testShijiBadgeLoadsShijiLevelsOnly() {
        let repo = GameDataRepository()
        let shijiBadge = BadgeModel(
            id: "badge_shiji",
            name: "太史公印",
            sealText: "太史\n公印",
            category: .classics,
            description: "史家之绝唱，无韵之离骚",
            requirementDescription: "解锁《史记》典故关卡",
            imageName: "badge_shiji.jpg"
        )
        
        let levels = repo.levelsForBadge(shijiBadge)
        XCTAssertFalse(levels.isEmpty, "史记关卡列表不应为空")
        
        for level in levels {
            XCTAssertFalse(level.source.contains("诗经"), "史记关卡绝不应包含诗经内容，当前出处：\(level.source)")
        }
    }
    
    func testCrossThemePhraseCompletionSynchronization() {
        let repo = GameDataRepository()
        repo.resetProgress()
        
        let level1 = repo.levels[0] // e.g. "关关雎鸠"
        let targetPhrase = level1.targetPhrase
        
        repo.completeLevel(level1)
        
        XCTAssertTrue(repo.userProgress.learnedPhrases.contains(targetPhrase))
        
        // 验证所有拥有该 targetPhrase 的关卡均被判定为已完成
        let matchingLevels = repo.levels.filter { $0.targetPhrase == targetPhrase }
        XCTAssertGreaterThan(matchingLevels.count, 0)
        for ml in matchingLevels {
            XCTAssertTrue(repo.isLevelCompleted(ml.id), "所有匹配 '\(targetPhrase)' 的关卡 (ID: \(ml.id)) 均应全域标记完成")
        }
    }
    
    func testFreshReplayModeToggle() {
        let repo = GameDataRepository()
        let themeKey = "badge_shiji"
        
        XCTAssertFalse(repo.isThemeInFreshPlay(themeKey))
        repo.toggleFreshReplayMode(for: themeKey)
        XCTAssertTrue(repo.isThemeInFreshPlay(themeKey))
        repo.toggleFreshReplayMode(for: themeKey)
        XCTAssertFalse(repo.isThemeInFreshPlay(themeKey))
    }
}
