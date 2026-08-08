import XCTest
@testable import luDuanCore

final class TwoHundredBadgesTests: XCTestCase {
    
    func testRepositoryContainsAtLeast200Badges() {
        let repo = GameDataRepository()
        XCTAssertGreaterThanOrEqual(repo.badges.count, 200, "Badges count should be at least 200")
    }
    
    func testAllBadgeIdsAreUnique() {
        let repo = GameDataRepository()
        let ids = repo.badges.map { $0.id }
        let uniqueIds = Set(ids)
        XCTAssertEqual(ids.count, uniqueIds.count, "All badge IDs must be unique without duplicates")
    }
    
    func testFourCategoriesExistAndAreNotEmpty() {
        let repo = GameDataRepository()
        for category in BadgeCategory.allCases {
            let filtered = repo.badges.filter { $0.category == category }
            XCTAssertFalse(filtered.isEmpty, "Category \(category.rawValue) should contain badges")
        }
    }
}
