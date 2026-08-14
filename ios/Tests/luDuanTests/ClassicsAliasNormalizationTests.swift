import XCTest
@testable import luDuanCore

final class ClassicsAliasNormalizationTests: XCTestCase {
    
    func testNoSlashAliasesInWords() {
        let repo = GameDataRepository.shared
        XCTAssertFalse(repo.allWords.isEmpty)
        
        for w in repo.allWords {
            XCTAssertFalse(w.source.contains("/"), "Source should not contain slash: \(w.source)")
            XCTAssertFalse(w.source.contains("／"), "Source should not contain fullwidth slash: \(w.source)")
        }
    }
    
    func testGuanCangHaiIsUnified() {
        let repo = GameDataRepository.shared
        let guanCangHaiWords = repo.allWords.filter { $0.source.contains("观沧海") }
        
        // 验证《观沧海》所有 5 处词句合并到了同一个典籍名下
        XCTAssertEqual(guanCangHaiWords.count, 5, "《观沧海》应该包含 5 条名句")
        let phrases = Set(guanCangHaiWords.map { $0.phrase })
        XCTAssertTrue(phrases.contains("东临碣石"))
        XCTAssertTrue(phrases.contains("水何澹澹"))
        XCTAssertTrue(phrases.contains("星汉灿烂"))
        XCTAssertTrue(phrases.contains("秋风萧瑟"))
        XCTAssertTrue(phrases.contains("日月之行"))
    }
    
    func testGuiSuiShouIsUnified() {
        let repo = GameDataRepository.shared
        let guiSuiShouWords = repo.allWords.filter { $0.source.contains("龟虽寿") }
        
        // 验证《龟虽寿》所有 3 处名句合并到了同一个典籍名下
        XCTAssertEqual(guiSuiShouWords.count, 3, "《龟虽寿》应该包含 3 条名句")
        let phrases = Set(guiSuiShouWords.map { $0.phrase })
        XCTAssertTrue(phrases.contains("老骥伏枥"))
        XCTAssertTrue(phrases.contains("烈士暮年"))
        XCTAssertTrue(phrases.contains("神龟虽寿"))
    }
    
    func testClassicsBadgesHaveNoSlash() {
        let repo = GameDataRepository.shared
        for badge in repo.badges {
            XCTAssertFalse(badge.name.contains("/"), "Badge name should not contain slash: \(badge.name)")
            XCTAssertFalse(badge.name.contains("／"), "Badge name should not contain fullwidth slash: \(badge.name)")
        }
    }
}
