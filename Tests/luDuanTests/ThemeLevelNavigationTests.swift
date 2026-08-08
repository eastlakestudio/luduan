import XCTest
@testable import luDuanCore

final class ThemeLevelNavigationTests: XCTestCase {
    
    func testThemeProgressInfoAndPreviousLevelNavigation() {
        let repository = GameDataRepository()
        repository.resetProgress()
        
        let levels = repository.levels
        XCTAssertGreaterThan(levels.count, 0)
        
        guard let firstLevel = levels.first else { return }
        
        let info = repository.themeProgressInfo(for: firstLevel)
        XCTAssertEqual(info.currentIndex, 1)
        XCTAssertGreaterThan(info.totalCount, 0)
        XCTAssertEqual(info.completedCount, 0)
        
        // 测试上一词在前一关为空，后一关不为空
        let prevFromFirst = repository.previousLevel(before: firstLevel)
        XCTAssertNil(prevFromFirst)
        
        // 完成第一关并进入第二关
        repository.completeLevel(firstLevel)
        if let secondLevel = repository.nextLevel(after: firstLevel) {
            let secondInfo = repository.themeProgressInfo(for: secondLevel)
            XCTAssertEqual(secondInfo.currentIndex, 2)
            XCTAssertEqual(secondInfo.completedCount, 1)
            
            let prevFromSecond = repository.previousLevel(before: secondLevel)
            XCTAssertNotNil(prevFromSecond)
            XCTAssertEqual(prevFromSecond?.id, firstLevel.id)
        }
    }
}
