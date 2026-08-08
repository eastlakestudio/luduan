import XCTest
@testable import HornedFoxCore

final class TileMatrixTests: XCTestCase {
    var repository: GameDataRepository!
    
    override func setUp() {
        super.setUp()
        repository = GameDataRepository()
        repository.resetProgress()
    }
    
    func test16TileMatrixGeneratorCountAndTargetChars() {
        guard let level = repository.levels.first else { return }
        XCTAssertGreaterThanOrEqual(level.tileMatrix.count, 16)
        
        let targetChars = Set(Array(level.targetPhrase).map { String($0) })
        let tileMatrixChars = Set(level.tileMatrix)
        XCTAssertTrue(targetChars.isSubset(of: tileMatrixChars))
    }
    
    func testPuzzleEngineResets16TileMatrixOnLevelLoad() {
        guard let level = repository.levels.first else { return }
        let engine = PuzzleEngine(level: level)
        XCTAssertGreaterThanOrEqual(engine.tiles.count, 16)
        XCTAssertTrue(engine.selectedIndices.isEmpty)
        XCTAssertFalse(engine.isCompleted)
    }
}
