import XCTest
@testable import HornedFoxCore

final class PuzzleEngineTests: XCTestCase {
    var sampleLevel: LevelModel!
    
    override func setUp() {
        super.setUp()
        sampleLevel = LevelModel(
            id: "test_01",
            theme: .shihan,
            title: "破釜沉舟",
            targetPhrase: "破釜沉舟",
            tileMatrix: ["破", "釜", "沉", "舟", "背", "水", "一", "战"],
            annotation: "测试注音",
            story: "测试典故故事",
            source: "《史记》",
            rewardBadgeId: "badge_xiangyu"
        )
    }
    
    func testSelectTileAndCurrentInput() {
        let engine = PuzzleEngine(level: sampleLevel)
        let poIdx = engine.tiles.firstIndex(of: "破")!
        let fuIdx = engine.tiles.firstIndex(of: "釜")!
        
        XCTAssertEqual(engine.currentInput, "")
        
        engine.selectTile(at: poIdx) // "破"
        engine.selectTile(at: fuIdx) // "釜"
        
        XCTAssertEqual(engine.currentInput, "破釜")
        XCTAssertEqual(engine.selectedIndices, [poIdx, fuIdx])
    }
    
    func testUnselectTile() {
        let engine = PuzzleEngine(level: sampleLevel)
        let poIdx = engine.tiles.firstIndex(of: "破")!
        let fuIdx = engine.tiles.firstIndex(of: "釜")!
        
        engine.selectTile(at: poIdx) // "破"
        engine.selectTile(at: fuIdx) // "釜"
        engine.unselectTile(at: 0) // 移除第一个选择的 "破"
        
        XCTAssertEqual(engine.currentInput, "釜")
        XCTAssertEqual(engine.selectedIndices, [fuIdx])
    }
    
    func testClearInput() {
        let engine = PuzzleEngine(level: sampleLevel)
        let poIdx = engine.tiles.firstIndex(of: "破")!
        let fuIdx = engine.tiles.firstIndex(of: "釜")!
        
        engine.selectTile(at: poIdx)
        engine.selectTile(at: fuIdx)
        engine.clearInput()
        
        XCTAssertEqual(engine.currentInput, "")
        XCTAssertTrue(engine.selectedIndices.isEmpty)
    }
    
    func testCorrectAnswerMatching() {
        let engine = PuzzleEngine(level: sampleLevel)
        let poIdx = engine.tiles.firstIndex(of: "破")!
        let fuIdx = engine.tiles.firstIndex(of: "釜")!
        let chenIdx = engine.tiles.firstIndex(of: "沉")!
        let zhouIdx = engine.tiles.firstIndex(of: "舟")!
        
        engine.selectTile(at: poIdx)
        engine.selectTile(at: fuIdx)
        engine.selectTile(at: chenIdx)
        engine.selectTile(at: zhouIdx)
        
        XCTAssertTrue(engine.isCompleted)
        XCTAssertEqual(engine.lastCheckState, .success)
    }
    
    func testIncorrectAnswerMatching() {
        let engine = PuzzleEngine(level: sampleLevel)
        let targetChars = ["破", "釜", "沉", "舟"]
        let wrongIndices = engine.tiles.enumerated()
            .filter { !targetChars.contains($0.element) }
            .map { $0.offset }
            .prefix(4)
        
        for idx in wrongIndices {
            engine.selectTile(at: idx)
        }
        
        XCTAssertFalse(engine.isCompleted)
        XCTAssertEqual(engine.lastCheckState, .incorrect)
    }
    
    func testProvideHint() {
        let engine = PuzzleEngine(level: sampleLevel)
        let poIdx = engine.tiles.firstIndex(of: "破")!
        let fuIdx = engine.tiles.firstIndex(of: "釜")!
        
        // 当前已选 "破"
        engine.selectTile(at: poIdx)
        
        // 请求提示下一个字 "釜"
        let hintIndex = engine.provideHint()
        XCTAssertEqual(hintIndex, fuIdx)
        XCTAssertEqual(engine.highlightedTileIndex, fuIdx)
    }
}
