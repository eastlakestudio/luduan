import XCTest
@testable import luDuanCore

final class JsonSeedLoaderTests: XCTestCase {
    
    func testAll17JsonSeedFilesCanBeLoaded() {
        let fileNames = [
            "shihan", "shijing", "tangsong", "lunyu", "daodejing",
            "mengzi", "zhongyong", "guoyu", "chunqiu", "yanshijiaxun",
            "chuanxilu", "caigentan", "rizhilu", "xiaochuangyouji",
            "zengguofanjiashu", "xiyouji", "hongloumeng"
        ]
        
        for name in fileNames {
            let seeds = Classic10000LevelsEngine.loadSeeds(named: name)
            XCTAssertFalse(seeds.isEmpty, "Failed to load JSON seed file: \(name).json")
        }
    }
    
    func testLongPoetryPhrasesCanBeGenerated() {
        let level = Classic10000LevelsEngine.level(at: 3504) // 既见君子云胡不喜
        XCTAssertGreaterThanOrEqual(level.targetPhrase.count, 4)
        XCTAssertGreaterThanOrEqual(level.tileMatrix.count, 16)
    }
}
