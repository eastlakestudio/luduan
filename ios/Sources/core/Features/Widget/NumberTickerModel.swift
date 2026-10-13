import Foundation

/// 桌面小组件秒级数字状态模型
public struct NumberTickerState: Equatable, Sendable {
    /// 计时器基准时间（正计时从此开始递增，倒计时作为起点）
    public let startDate: Date
    /// 倒计时目标截止时间
    public let targetDate: Date
    /// 倒计时默认跨度（默认 10 分钟 = 600 秒）
    public static let defaultDuration: TimeInterval = 600
    
    public init(startDate: Date, duration: TimeInterval = defaultDuration) {
        self.startDate = startDate
        self.targetDate = startDate.addingTimeInterval(duration)
    }
    
    /// 计算已过去秒数（用于单测与离散验证）
    public func elapsedSeconds(at current: Date = Date()) -> Int {
        max(0, Int(current.timeIntervalSince(startDate)))
    }
    
    /// 计算剩余秒数
    public func remainingSeconds(at current: Date = Date()) -> Int {
        max(0, Int(targetDate.timeIntervalSince(current)))
    }
    
    /// 是否倒计时已结束
    public func isFinished(at current: Date = Date()) -> Bool {
        current >= targetDate
    }
}
