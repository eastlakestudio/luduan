import XCTest
@testable import luDuanCore

final class TenThousandLevelsTests: XCTestCase {
    
    func testTotalLevelsCountIs10000() {
        XCTAssertEqual(Classic10000LevelsEngine.totalLevelsCount, 10000)
    }
    
    func testLevelGenerationAtKeyMilestones() {
        let level1 = Classic10000LevelsEngine.level(at: 0)
        XCTAssertEqual(level1.id, "level_1")
        XCTAssertEqual(level1.theme, .shijing)
        XCTAssertEqual(level1.tileMatrix.count, 16)
        
        let level2501 = Classic10000LevelsEngine.level(at: 2500)
        XCTAssertEqual(level2501.id, "level_2501")
        XCTAssertEqual(level2501.theme, .shihan)
        XCTAssertEqual(level2501.tileMatrix.count, 16)
        
        let level7001 = Classic10000LevelsEngine.level(at: 7000)
        XCTAssertEqual(level7001.id, "level_7001")
        XCTAssertEqual(level7001.theme, .tangsong)
        XCTAssertEqual(level7001.tileMatrix.count, 16)
        
        let level10000 = Classic10000LevelsEngine.level(at: 9999)
        XCTAssertEqual(level10000.id, "level_10000")
        XCTAssertEqual(level10000.theme, .shihan)
        XCTAssertEqual(level10000.tileMatrix.count, 16)
    }
    
    func testGenerationPerformance10000Levels() {
        measure {
            for i in 0..<1000 {
                let lvl = Classic10000LevelsEngine.level(at: i * 10)
                XCTAssertEqual(lvl.tileMatrix.count, 16)
            }
        }
    }
}
