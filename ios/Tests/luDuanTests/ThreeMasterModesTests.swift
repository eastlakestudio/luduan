import XCTest
@testable import luDuanCore

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
    
    func testBadgeImageResolverCoverage() {
        // Academic
        XCTAssertEqual(ChineseSealView.resolveImageName(for: "badge_level_1"), "badge_academic_tongsheng")
        XCTAssertEqual(ChineseSealView.resolveImageName(for: "badge_level_2"), "badge_academic_xiucai")
        XCTAssertEqual(ChineseSealView.resolveImageName(for: "badge_level_8"), "badge_academic_shoufu")
        
        // Classics & Authors
        XCTAssertEqual(ChineseSealView.resolveImageName(for: "badge_default_book", text: "《诗经·关雎》"), "badge_shijing")
        XCTAssertEqual(ChineseSealView.resolveImageName(for: "badge_default_book", text: "《史记·项羽本纪》"), "badge_shiji")
        XCTAssertEqual(ChineseSealView.resolveImageName(for: "badge_default_book", text: "《论语·学而》"), "badge_kongzi")
        XCTAssertEqual(ChineseSealView.resolveImageName(for: nil, text: "李白诗集"), "badge_libai")
        XCTAssertEqual(ChineseSealView.resolveImageName(for: nil, text: "苏轼东坡志林"), "badge_sushi")
        XCTAssertEqual(ChineseSealView.resolveImageName(for: nil, text: "岳飞满江红"), "badge_yuefei")
        
        // Practical Themes
        let practicalImg = ChineseSealView.resolveImageName(for: "badge_theme_修身齐家", text: "修身齐家")
        XCTAssertNotNil(practicalImg)
        XCTAssertTrue(practicalImg?.hasPrefix("badge_prac_") ?? false)
    }
    
    func testCharacterBadgesExistAndImagesAreResolved() {
        let charBadges = PresetData.characterBadges
        XCTAssertEqual(charBadges.count, 64, "All 64 historical character badges must be configured")
        
        for badge in charBadges {
            XCTAssertEqual(badge.category, .character)
            let resolved = ChineseSealView.resolveImageName(for: badge.imageName, text: badge.name)
            XCTAssertNotNil(resolved, "Character badge \(badge.name) must resolve to an image asset")
            XCTAssertFalse(resolved?.isEmpty ?? true)
        }
        
        let allBadges = PresetData.defaultBadges
        let loadedCharacters = allBadges.filter { $0.category == .character }
        XCTAssertGreaterThanOrEqual(loadedCharacters.count, 64, "Default badges must contain character badges")
    }
}
