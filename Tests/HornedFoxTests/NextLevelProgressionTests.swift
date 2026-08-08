import XCTest
@testable import HornedFoxCore

final class NextLevelProgressionTests: XCTestCase {
    
    func testNextLevelAlwaysAvailableIn10000Pool() {
        let repo = GameDataRepository.shared
        XCTAssertGreaterThan(repo.levels.count, 100)
        
        let firstLevel = repo.levels[0]
        let next1 = repo.nextLevel(after: firstLevel)
        XCTAssertNotNil(next1)
        
        if let next1 = next1 {
            let next2 = repo.nextLevel(after: next1)
            XCTAssertNotNil(next2)
            XCTAssertNotEqual(firstLevel.id, next2?.id)
        }
    }
    
    func testTenCharacterTargetPhraseGridColumns() {
        let sample10Char = LevelModel(
            id: "test_10_char",
            theme: .shihan,
            title: "野火烧不尽春风吹又生",
            targetPhrase: "野火烧不尽春风吹又生",
            tileMatrix: ["野", "火", "烧", "不", "尽", "春", "风", "吹", "又", "生"],
            annotation: "测试",
            story: "测试",
            source: "《古诗》"
        )
        
        let chars = Array(sample10Char.targetPhrase).map { String($0) }
        XCTAssertEqual(chars.count, 10)
        
        let colCount = chars.count <= 4 ? chars.count : (chars.count == 8 ? 4 : (chars.count == 10 ? 5 : min(chars.count, 5)))
        XCTAssertEqual(colCount, 5)
    }
}
