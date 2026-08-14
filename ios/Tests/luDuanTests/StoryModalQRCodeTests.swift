import XCTest
@testable import luDuanCore

final class StoryModalQRCodeTests: XCTestCase {
    
    func testStoryModalShareTextContainsLuduanAndAppStoreUrl() {
        let targetPhrase = "关关雎鸠"
        let story = "关关雎鸠在河之洲"
        let shareText = "【甪端字游·典故卡片】我已成功解破《\(targetPhrase)》！典故故事：《\(story)》。"
        
        XCTAssertTrue(shareText.contains("甪端字游"))
        XCTAssertFalse(shareText.contains("乘黄"))
        XCTAssertFalse(shareText.contains("https://apps.apple.com"))
    }
}
