import XCTest
@testable import HornedFoxCore

final class RealVoiceMatchingTests: XCTestCase {
    
    func testRandomUnmatchedVoiceInputSelectsZeroTiles() {
        let level = LevelModel(
            id: "test_voice_01",
            theme: .shihan,
            title: "破釜沉舟",
            targetPhrase: "破釜沉舟",
            tileMatrix: ["破", "釜", "沉", "舟", "天", "地", "玄", "黄", "宇", "宙", "洪", "荒", "日", "月", "盈", "仄"],
            annotation: "测试",
            story: "测试",
            source: "《史记》"
        )
        let engine = PuzzleEngine(level: level)
        
        // 模拟乱说话 (乱字在 16 字矩阵中不存在)
        engine.processVoiceInputString("哈哈乱说话咯")
        
        // 应该 0 字选入答题槽
        XCTAssertEqual(engine.selectedIndices.count, 0)
    }
    
    func testMatchingVoiceInputSelectsExactTilesInOrder() {
        let level = LevelModel(
            id: "test_voice_02",
            theme: .shihan,
            title: "破釜沉舟",
            targetPhrase: "破釜沉舟",
            tileMatrix: ["破", "釜", "沉", "舟", "天", "地", "玄", "黄", "宇", "宙", "洪", "荒", "日", "月", "盈", "仄"],
            annotation: "测试",
            story: "测试",
            source: "《史记》"
        )
        let engine = PuzzleEngine(level: level)
        
        // 模拟正确口述 "破釜"
        engine.processVoiceInputString("我认为应该是破釜")
        
        // 应该选中 "破" (index 0) 和 "釜" (index 1)
        XCTAssertEqual(engine.selectedIndices.count, 2)
        XCTAssertEqual(engine.tiles[engine.selectedIndices[0]], "破")
        XCTAssertEqual(engine.tiles[engine.selectedIndices[1]], "釜")
    }
    
    func testHomophoneVoiceInputSelectsMatchingTilesByPinyin() {
        let level = LevelModel(
            id: "test_voice_03",
            theme: .shihan,
            title: "破釜沉舟",
            targetPhrase: "破釜沉舟",
            tileMatrix: ["破", "釜", "沉", "舟", "天", "地", "玄", "黄", "宇", "宙", "洪", "荒", "日", "月", "盈", "仄"],
            annotation: "测试",
            story: "测试",
            source: "《史记》"
        )
        let engine = PuzzleEngine(level: level)
        
        // 模拟同音字口述 "破辅" ("辅"与"釜"均为 fu 音)
        engine.processVoiceInputString("破辅")
        
        // 借助拼音读音匹配算法，成功将同音字 "辅" 匹配并选中字块矩阵中的 "釜"
        XCTAssertEqual(engine.selectedIndices.count, 2)
        XCTAssertEqual(engine.tiles[engine.selectedIndices[0]], "破")
        XCTAssertEqual(engine.tiles[engine.selectedIndices[1]], "釜")
    }
}
