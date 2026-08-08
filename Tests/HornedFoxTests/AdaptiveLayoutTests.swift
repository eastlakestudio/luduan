import XCTest
import SwiftUI
@testable import HornedFoxCore

final class AdaptiveLayoutTests: XCTestCase {
    
    func testGridColumnsCalculationForCompactAndRegular() {
        // iPhone 紧凑屏测试
        let compactGrid = AdaptiveLayoutHelper.gridColumns(
            for: .compact,
            compactColumns: 3,
            regularColumns: 6
        )
        XCTAssertEqual(compactGrid.count, 3, "Compact size class should return 3 columns")
        
        // iPad 宽屏测试
        let regularGrid = AdaptiveLayoutHelper.gridColumns(
            for: .regular,
            compactColumns: 3,
            regularColumns: 6
        )
        XCTAssertEqual(regularGrid.count, 6, "Regular size class should return 6 columns")
    }
    
    func testBadgeImageNameAssociations() {
        let repository = GameDataRepository.shared
        XCTAssertGreaterThanOrEqual(repository.badges.count, 200, "Badges count should be at least 200")
        
        if let xiangyuBadge = repository.badges.first(where: { $0.id == "badge_xiangyu" }) {
            XCTAssertEqual(xiangyuBadge.imageName, "badge_xiangyu")
        }
        
        for badge in repository.badges {
            XCTAssertFalse(badge.name.isEmpty, "Badge name should not be empty")
            XCTAssertFalse(badge.sealText.isEmpty, "Badge sealText should not be empty")
        }
    }
}
