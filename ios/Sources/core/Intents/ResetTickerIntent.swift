import AppIntents
import WidgetKit
import Foundation

public struct ResetTickerIntent: AppIntent {
    public static var title: LocalizedStringResource = "重置基准秒数"
    public static var description = IntentDescription("重置桌面数字小组件的计时基准时间。")
    public static var openAppWhenRun: Bool = false

    public init() {}

    public func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.eastlakestudio.luduan") ?? UserDefaults.standard
        defaults.set(Date().timeIntervalSince1970, forKey: "numberTickerBaseTimestamp")
        WidgetCenter.shared.reloadTimelines(ofKind: "NumberTickerWidget")
        return .result()
    }
}
