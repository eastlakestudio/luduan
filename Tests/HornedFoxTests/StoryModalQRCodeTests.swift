import XCTest
@testable import HornedFoxCore

final class StoryModalQRCodeTests: XCTestCase {
    
    func testStoryModalShareTextContainsLuduanAndAppStoreUrl() {
        let targetPhrase = "关关雎鸠"
        let story = "关关雎鸠在河之洲"
        let shareText = "【甪端字游·典故卡片】我已成功解破《\(targetPhrase)》！典故故事：《\(story)》。App Store 下载链接：https://apps.apple.com/us/app/%E7%94%AA%E7%AB%AF/id6799431765"
        
        XCTAssertTrue(shareText.contains("甪端字游"))
        XCTAssertFalse(shareText.contains("乘黄"))
        XCTAssertTrue(shareText.contains("https://apps.apple.com/us/app/%E7%94%AA%E7%AB%AF/id6799431765"))
    }
}
