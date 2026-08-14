import XCTest
@testable import luDuanCore

final class SharePosterAdTests: XCTestCase {
    
    func testSharePosterContainsMascotSourceAndQRCodeUrl() {
        let sampleLevel = LevelModel(
            id: "ad_test_01",
            theme: .shihan,
            title: "关关雎鸠",
            targetPhrase: "关关雎鸠",
            tileMatrix: ["关", "雎", "鸠"],
            annotation: "测试",
            story: "关关雎鸠在河之洲",
            source: "诗经·国风"
        )
        
        let poster = SharePosterCardView(level: sampleLevel, completedCount: 10)
        XCTAssertNotNil(poster)
        
        let shareText = "【甪端字游】我已累计通关 10 词古风字游！神兽甪端伴学，万关典籍名篇。快来一起体验《甪端字游》！"
        
        XCTAssertTrue(shareText.contains("甪端字游"))
        XCTAssertFalse(shareText.contains("https://apps.apple.com"))
    }
}
