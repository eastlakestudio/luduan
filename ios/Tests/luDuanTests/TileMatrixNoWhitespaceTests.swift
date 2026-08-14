import XCTest
@testable import luDuanCore

final class TileMatrixNoWhitespaceTests: XCTestCase {
    
    func testAllUniqueCharsContainsNoWhitespaceOrNewlines() {
        let chars = Classic10000LevelsEngine.allUniqueChars
        XCTAssertFalse(chars.isEmpty)
        
        for char in chars {
            XCTAssertFalse(char.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "Character pool item must not be empty or whitespace: '\(char)'")
            XCTAssertFalse(char.contains("\n"), "Character must not contain newline")
            XCTAssertFalse(char.contains("\r"), "Character must not contain carriage return")
            XCTAssertFalse(char.contains(" "), "Character must not contain space")
        }
    }
    
    func testLevelTileMatrixContainsNoEmptyStrings() {
        let repo = GameDataRepository.shared
        let sampleWords = Array(repo.allWords.prefix(100))
        
        for word in sampleWords {
            let level = Classic10000LevelsEngine.levelFromWord(word)
            let engine = PuzzleEngine(level: level)
            
            XCTAssertEqual(engine.tiles.count, max(12, level.targetPhrase.count))
            for tile in engine.tiles {
                XCTAssertFalse(tile.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "Tile in matrix must not be blank in level \(level.targetPhrase)")
            }
        }
    }
}
