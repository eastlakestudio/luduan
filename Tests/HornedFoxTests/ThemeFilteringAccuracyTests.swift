import XCTest
@testable import HornedFoxCore

final class ThemeFilteringAccuracyTests: XCTestCase {
    
    func testPreQinLevelsContainNoTangPoetry() {
        let level1 = Classic10000LevelsEngine.level(at: 0, categoryName: "先秦典籍源头")
        
        XCTAssertEqual(level1.displayCategoryName, "先秦典籍源头")
        // Level 1 of Pre-Qin should be Guan Guan Ju Jiu from Shi Jing, not 床前明月光
        XCTAssertNotEqual(level1.targetPhrase, "床前明月光")
        XCTAssertTrue(level1.source.contains("诗经") || level1.source.contains("先秦") || level1.source.contains("论语") || level1.source.contains("道德经"))
    }
    
    func testTangSongLevelsContainTangPoetry() {
        let tangLevel = Classic10000LevelsEngine.level(at: 7000, categoryName: "唐宋诗词")
        XCTAssertEqual(tangLevel.displayCategoryName, "唐宋诗词")
        XCTAssertEqual(tangLevel.theme, .tangsong)
    }
}
