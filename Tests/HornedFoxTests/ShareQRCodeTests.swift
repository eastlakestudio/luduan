import XCTest
@testable import HornedFoxCore

final class ShareQRCodeTests: XCTestCase {
    
    func testAppStoreUrlConstant() {
        let appStoreUrl = "https://apps.apple.com/us/app/%E7%94%AA%E7%AB%AF/id6799431765"
        XCTAssertTrue(appStoreUrl.contains("id6799431765"))
        XCTAssertTrue(appStoreUrl.contains("apps.apple.com"))
    }
    
    func testLuduanBrandNameInMilestonePoster() {
        let posterText = "【甪端字游·金榜题名捷报】"
        XCTAssertTrue(posterText.contains("甪端字游"))
        XCTAssertFalse(posterText.contains("乘黄"))
    }
}
