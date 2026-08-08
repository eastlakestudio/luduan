import XCTest
@testable import HornedFoxCore

final class ThreeMasterModesTests: XCTestCase {
    
    func testThreeMasterDimensionsExist() {
        let dimensions = ThemeDimension.allCases
        XCTAssertEqual(dimensions.count, 3)
        XCTAssertEqual(ThemeDimension.academic.rawValue, "学阶功名")
        XCTAssertEqual(ThemeDimension.classics.rawValue, "典籍名篇")
        XCTAssertEqual(ThemeDimension.practical.rawValue, "处世修养")
    }
    
    func testAcademicRanksSeparatedTongShengAndXiuCai() {
        let ranks = AcademicRank.allCases
        XCTAssertEqual(ranks.count, 6)
        XCTAssertEqual(ranks[0], .tongSheng)
        XCTAssertEqual(ranks[1], .xiuCai)
        XCTAssertNotEqual(ranks[0].rawValue, ranks[1].rawValue, "Tong-Sheng and Xiu-Cai must be separated")
        
        XCTAssertEqual(ranks[0].rawValue, "童生", "Title must be simplified without redundant suffix")
        XCTAssertEqual(ranks[1].rawValue, "秀才", "Title must be simplified without redundant suffix")
        
        XCTAssertEqual(ranks[0].mingDynastyCartoonImageName, "badge_academic_tongsheng")
        XCTAssertEqual(ranks[1].mingDynastyCartoonImageName, "badge_academic_xiucai")
        XCTAssertEqual(ranks[5].mingDynastyCartoonImageName, "badge_academic_shoufu")
    }
    
    func testClassicalNomenclatureForPracticalThemes() {
        XCTAssertEqual(PracticalTheme.huozhi.rawValue, "《计然货殖》")
        XCTAssertEqual(PracticalTheme.bingfa.rawValue, "《兵法韬略》")
    }
    
    func testThreeStateBadgeViewProgressBoundaries() {
        let emptyBadge = ThreeStateBadgeView(sealText: "童生\n启蒙", progressRatio: 0.0)
        XCTAssertEqual(emptyBadge.progressRatio, 0.0)
        
        let halfBadge = ThreeStateBadgeView(sealText: "秀才\n中考", progressRatio: 0.45)
        XCTAssertEqual(halfBadge.progressRatio, 0.45)
        
        let fullBadge = ThreeStateBadgeView(sealText: "首辅\n帝师", progressRatio: 1.0)
        XCTAssertEqual(fullBadge.progressRatio, 1.0)
    }
}
