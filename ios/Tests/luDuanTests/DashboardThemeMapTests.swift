import XCTest
@testable import luDuanCore

final class DashboardThemeMapTests: XCTestCase {
    var repository: GameDataRepository!
    
    override func setUp() {
        super.setUp()
        repository = GameDataRepository()
        repository.resetProgress()
    }
    
    func testPetEvolutionScoreFreeLevelBased() {
        var pet = PetModel(completedLevelCount: 0)
        XCTAssertEqual(pet.currentStage, .youth)
        XCTAssertEqual(pet.nextStageRequiredLevels, 3)
        
        pet = PetModel(completedLevelCount: 3)
        XCTAssertEqual(pet.currentStage, .ink)
        XCTAssertEqual(pet.nextStageRequiredLevels, 6)
        
        pet = PetModel(completedLevelCount: 6)
        XCTAssertEqual(pet.currentStage, .celestial)
        XCTAssertNil(pet.nextStageRequiredLevels)
    }
    
    func testActiveThemeBinding() {
        XCTAssertEqual(repository.userProgress.lastActiveTheme, .shihan)
        
        repository.setActiveTheme(.shijing)
        XCTAssertEqual(repository.userProgress.lastActiveTheme, .shijing)
    }
    
    func testCircularProgressCalculation() {
        let shihanLevels = repository.levels.filter { $0.theme == .shihan }
        XCTAssertFalse(shihanLevels.isEmpty)
        
        let initialCompleted = shihanLevels.filter { repository.isLevelCompleted($0.id) }.count
        XCTAssertEqual(initialCompleted, 0)
        
        repository.completeLevel(shihanLevels[0])
        let newCompleted = shihanLevels.filter { repository.isLevelCompleted($0.id) }.count
        XCTAssertGreaterThanOrEqual(newCompleted, 1)
    }
}
