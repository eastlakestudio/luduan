import XCTest
@testable import HornedFoxCore

final class EyeCareAndDimensionTests: XCTestCase {
    
    func testPinyinHelperLookup() {
        XCTAssertEqual(PinyinHelper.pinyin(for: "破"), "pò")
        XCTAssertEqual(PinyinHelper.pinyin(for: "釜"), "fǔ")
        XCTAssertEqual(PinyinHelper.pinyin(for: "沉"), "chén")
        XCTAssertEqual(PinyinHelper.pinyin(for: "舟"), "zhōu")
    }
    
    func testThemeDimensionLabels() {
        XCTAssertEqual(CultureTheme.shihan.academicGradeLabel, "初中文言典故")
        XCTAssertEqual(CultureTheme.shijing.academicGradeLabel, "小学风雅启蒙")
        XCTAssertEqual(CultureTheme.tangsong.academicGradeLabel, "高中宋词名篇")
        
        XCTAssertEqual(CultureTheme.shihan.officialRankLabel, "进士红袍功名")
        XCTAssertEqual(CultureTheme.shijing.officialRankLabel, "秀才童生功名")
        XCTAssertEqual(CultureTheme.tangsong.officialRankLabel, "翰林学士功名")
    }
    
    func testSoundManagerSingleton() {
        XCTAssertNotNil(SoundManager.shared)
    }
}
