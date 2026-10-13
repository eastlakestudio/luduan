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
        guard let word = GameDataRepository.shared.allWords.first(where: { $0.phrase.count >= 4 }) else {
            XCTFail("No poetry phrase found")
            return
        }
        let level = Classic10000LevelsEngine.levelFromWord(word)
        XCTAssertGreaterThanOrEqual(level.targetPhrase.count, 4)
        XCTAssertGreaterThanOrEqual(level.tileMatrix.count, 16)
    }
}
