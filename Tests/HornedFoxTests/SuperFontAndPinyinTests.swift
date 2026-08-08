import XCTest
@testable import HornedFoxCore

final class SuperFontAndPinyinTests: XCTestCase {
    
    func testPinyinAnnotationLookupForTargetPhrases() {
        let sample = "破釜沉舟"
        let chars = Array(sample).map { String($0) }
        let pinyins = chars.map { PinyinHelper.pinyin(for: $0) }
        
        XCTAssertEqual(pinyins.count, 4)
        XCTAssertEqual(pinyins[0], "pò")
        XCTAssertEqual(pinyins[1], "fǔ")
        XCTAssertEqual(pinyins[2], "chén")
        XCTAssertEqual(pinyins[3], "zhōu")
    }
    
    func testLevelContainsClassicalSourceAndStory() {
        let level = Classic10000LevelsEngine.level(at: 0)
        XCTAssertFalse(level.story.isEmpty)
        XCTAssertFalse(level.source.isEmpty)
    }
}
