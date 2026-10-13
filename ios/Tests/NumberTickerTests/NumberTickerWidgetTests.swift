import XCTest
@testable import luDuanCore

final class NumberTickerWidgetTests: XCTestCase {
    
    func testTickerStateDefaultDuration() {
        let now = Date()
        let state = NumberTickerState(startDate: now)
        
        XCTAssertEqual(state.startDate, now)
        XCTAssertEqual(state.targetDate.timeIntervalSince(now), NumberTickerState.defaultDuration, accuracy: 0.001)
        XCTAssertFalse(state.isFinished(at: now))
    }
    
    func testTickerStateCustomDuration() {
        let now = Date()
        let customDuration: TimeInterval = 120
        let state = NumberTickerState(startDate: now, duration: customDuration)
        
        XCTAssertEqual(state.targetDate.timeIntervalSince(now), customDuration, accuracy: 0.001)
        XCTAssertEqual(state.remainingSeconds(at: now), 120)
    }
    
    func testElapsedSecondsCalculation() {
        let now = Date()
        let state = NumberTickerState(startDate: now)
        
        // 当下为 0 秒
        XCTAssertEqual(state.elapsedSeconds(at: now), 0)
        
        // 45 秒后
        let after45s = now.addingTimeInterval(45)
        XCTAssertEqual(state.elapsedSeconds(at: after45s), 45)
        
        // 过去时间不返回负数
        let beforeNow = now.addingTimeInterval(-10)
        XCTAssertEqual(state.elapsedSeconds(at: beforeNow), 0)
    }
    
    func testRemainingSecondsAndFinished() {
        let now = Date()
        let state = NumberTickerState(startDate: now, duration: 300) // 5 分钟
        
        // 刚开始剩余 300 秒
        XCTAssertEqual(state.remainingSeconds(at: now), 300)
        XCTAssertFalse(state.isFinished(at: now))
        
        // 过了 200 秒剩余 100 秒
        let after200s = now.addingTimeInterval(200)
        XCTAssertEqual(state.remainingSeconds(at: after200s), 100)
        XCTAssertFalse(state.isFinished(at: after200s))
        
        // 到达目标时间
        let atEnd = now.addingTimeInterval(300)
        XCTAssertEqual(state.remainingSeconds(at: atEnd), 0)
        XCTAssertTrue(state.isFinished(at: atEnd))
        
        // 超过目标时间不返回负数
        let pastEnd = now.addingTimeInterval(350)
        XCTAssertEqual(state.remainingSeconds(at: pastEnd), 0)
        XCTAssertTrue(state.isFinished(at: pastEnd))
    }
    
    func testResetTickerIntentExecution() async throws {
        let intent = ResetTickerIntent()
        let beforeTime = Date().timeIntervalSince1970
        
        let result = try await intent.perform()
        XCTAssertNotNil(result)
        
        let defaults = UserDefaults(suiteName: "group.com.eastlakestudio.luduan") ?? UserDefaults.standard
        let stored = defaults.double(forKey: "numberTickerBaseTimestamp")
        
        XCTAssertGreaterThanOrEqual(stored, beforeTime)
    }
}
