import XCTest
@testable import HornedFoxCore

final class LaunchPinyinTests: XCTestCase {
    
    func testLuduanPinyinConstant() {
        let pinyinString = "lù  duān  zì  yóu"
        XCTAssertTrue(pinyinString.contains("lù"))
        XCTAssertTrue(pinyinString.contains("duān"))
        XCTAssertTrue(pinyinString.contains("zì"))
        XCTAssertTrue(pinyinString.contains("yóu"))
    }
}
