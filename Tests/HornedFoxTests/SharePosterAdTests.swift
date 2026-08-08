import XCTest
@testable import HornedFoxCore

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
        
        let shareText = "【甪端字游·典故卡片】我刚刚在《甪端字游》研读完典籍《\(sampleLevel.source)》中的【\(sampleLevel.targetPhrase)】！典故故事：“\(sampleLevel.story)”。快来体验神兽伴学与万关典籍古风手游！App Store 下载链接：https://apps.apple.com/us/app/%E7%94%AA%E7%AB%AF/id6799431765"
        
        XCTAssertTrue(shareText.contains("甪端字游"))
        XCTAssertTrue(shareText.contains("诗经·国风"))
        XCTAssertTrue(shareText.contains("https://apps.apple.com/us/app/%E7%94%AA%E7%AB%AF/id6799431765"))
    }
}
