import XCTest
@testable import HornedFoxCore

final class AdaptiveLayoutConstraintTests: XCTestCase {
    
    func testSingleRowVersusMultiRowPhraseDetection() {
        let singleRowLevel = LevelModel(
            id: "single_01",
            theme: .shihan,
            title: "破釜沉舟",
            targetPhrase: "破釜沉舟",
            tileMatrix: ["破", "釜", "沉", "舟"],
            annotation: "测试",
            story: "测试",
            source: "《史记》"
        )
        
        let multiRowLevel = LevelModel(
            id: "multi_01",
            theme: .shihan,
            title: "既见君子云胡不喜",
            targetPhrase: "既见君子云胡不喜",
            tileMatrix: ["既", "见", "君", "子", "云", "胡", "不", "喜"],
            annotation: "测试",
            story: "测试",
            source: "《诗经》"
        )
        
        XCTAssertFalse(singleRowLevel.targetPhrase.count > 4)
        XCTAssertTrue(multiRowLevel.targetPhrase.count > 4)
    }
}
