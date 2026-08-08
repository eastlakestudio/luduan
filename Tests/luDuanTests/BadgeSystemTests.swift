import XCTest
@testable import luDuanCore

final class BadgeSystemTests: XCTestCase {
    func testBadgeCategoriesCount() {
        let badges = PresetData.defaultBadges
        let categories = Set(badges.map { $0.category })
        
        XCTAssertTrue(categories.contains(.character))
        XCTAssertTrue(categories.contains(.academic))
        XCTAssertTrue(categories.contains(.classics))
        XCTAssertTrue(categories.contains(.practical))
    }
    
    func testBadgeFilterByCategory() {
        let badges = PresetData.defaultBadges
        let charBadges = badges.filter { $0.category == .character }
        
        XCTAssertGreaterThanOrEqual(charBadges.count, 50)
        XCTAssertTrue(charBadges.allSatisfy { $0.category == .character })
    }
}
