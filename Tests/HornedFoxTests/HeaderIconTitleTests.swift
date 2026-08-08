import XCTest
@testable import HornedFoxCore

final class HeaderIconTitleTests: XCTestCase {
    
    func testSingleLineTitleFormatting() {
        let repo = GameDataRepository.shared
        guard let level = repo.levels.first else {
            XCTFail("Levels should not be empty")
            return
        }
        
        let progress = repo.themeProgressInfo(for: level)
        let formattedTitle = "\(level.theme.rawValue) · 第 \(progress.currentIndex)/\(progress.totalCount) 词"
        
        XCTAssertFalse(formattedTitle.contains("\n"))
        XCTAssertGreaterThan(formattedTitle.count, 0)
    }
}
