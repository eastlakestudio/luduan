import XCTest
@testable import luDuanCore

final class DataPersistenceUpgradeTests: XCTestCase {
    
    func testUserProgressModelMergeUnionsLearnedPhrasesAndBadges() {
        var base = UserProgressModel(
            completedLevelIds: ["level_1"],
            learnedPhrases: ["关关雎鸠", "在河之洲"],
            unlockedBadgeIds: ["badge_tongsheng"],
            totalScore: 20
        )
        
        let updateFromOtherSource = UserProgressModel(
            completedLevelIds: ["level_2"],
            learnedPhrases: ["窈窕淑女", "君子好逑"],
            unlockedBadgeIds: ["badge_xiucai"],
            totalScore: 50
        )
        
        base.merge(with: updateFromOtherSource)
        
        // 验证字词只增不减（全部合并）
        XCTAssertEqual(base.learnedPhrases.count, 4)
        XCTAssertTrue(base.learnedPhrases.contains("关关雎鸠"))
        XCTAssertTrue(base.learnedPhrases.contains("在河之洲"))
        XCTAssertTrue(base.learnedPhrases.contains("窈窕淑女"))
        XCTAssertTrue(base.learnedPhrases.contains("君子好逑"))
        
        // 验证勋章全部合并
        XCTAssertEqual(base.unlockedBadgeIds.count, 2)
        XCTAssertTrue(base.unlockedBadgeIds.contains("badge_tongsheng"))
        XCTAssertTrue(base.unlockedBadgeIds.contains("badge_xiucai"))
        
        // 验证分数不会被低分覆盖
        XCTAssertGreaterThanOrEqual(base.totalScore, 50)
    }
    
    func testAppUpgradeSimulatedEmptyStateDoesNotOverwriteLearnedPhrases() {
        var existingProgress = UserProgressModel(
            learnedPhrases: ["学而时习之", "不亦说乎"],
            unlockedBadgeIds: ["badge_tongsheng"],
            totalScore: 100
        )
        
        let freshAppLaunchEmptyModel = UserProgressModel()
        
        existingProgress.merge(with: freshAppLaunchEmptyModel)
        
        // 即使有空模型接入，已有进度绝不丢失
        XCTAssertEqual(existingProgress.learnedPhrases.count, 2)
        XCTAssertEqual(existingProgress.unlockedBadgeIds.count, 1)
        XCTAssertEqual(existingProgress.totalScore, 100)
    }
    
    func testCompleteLevelPersistsLearnedPhrases() {
        let repo = GameDataRepository()
        let sampleLevel = LevelModel(
            id: "persistence_test_level",
            theme: .shihan,
            title: "关雎",
            targetPhrase: "关关雎鸠测试",
            tileMatrix: ["关", "雎", "鸠"],
            annotation: "测试",
            story: "测试典故",
            source: "诗经"
        )
        
        let beforeCount = repo.userProgress.learnedPhrases.count
        repo.completeLevel(sampleLevel)
        
        XCTAssertTrue(repo.isLevelCompleted("关关雎鸠测试"))
        XCTAssertGreaterThanOrEqual(repo.userProgress.learnedPhrases.count, beforeCount)
    }
}
