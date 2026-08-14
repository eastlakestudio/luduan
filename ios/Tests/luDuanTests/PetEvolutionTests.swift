import XCTest
@testable import luDuanCore

final class PetEvolutionTests: XCTestCase {
    
    func testYouthStageDefault() {
        let pet = PetModel(completedLevelCount: 0)
        XCTAssertEqual(pet.currentStage, PetEvolutionStage.youth)
        XCTAssertEqual(pet.nextStageRequiredLevels, 3)
    }
    
    func testInkStageEvolution() {
        let pet = PetModel(completedLevelCount: 3)
        XCTAssertEqual(pet.currentStage, PetEvolutionStage.ink)
        XCTAssertEqual(pet.nextStageRequiredLevels, 6)
    }
    
    func testCelestialStageEvolution() {
        let pet = PetModel(completedLevelCount: 6)
        XCTAssertEqual(pet.currentStage, PetEvolutionStage.celestial)
        XCTAssertNil(pet.nextStageRequiredLevels)
    }
}
