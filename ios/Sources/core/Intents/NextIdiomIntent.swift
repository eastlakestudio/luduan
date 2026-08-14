import AppIntents
import WidgetKit
import Foundation

public struct RefreshIdiomIntent: AppIntent {
    public static var title: LocalizedStringResource = "换一个"
    public static var description = IntentDescription("刷新小组件，显示下一个成语。")
    public static var openAppWhenRun: Bool = false

    public init() {}

    public func perform() async throws -> some IntentResult {
        WidgetCenter.shared.reloadTimelines(ofKind: "IdiomWidget")
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

public struct NextIdiomIntent: AppIntent {
    public static var title: LocalizedStringResource = "已学"
    public static var description = IntentDescription("标记当前成语为已学，并切换下一个成语。")
    public static var openAppWhenRun: Bool = false

    @Parameter(title: "Target Phrase", default: "")
    public var targetPhrase: String

    @Parameter(title: "Current Source", default: "")
    public var currentSource: String

    public init() {
        self.targetPhrase = ""
        self.currentSource = ""
    }

    public init(targetPhrase: String, currentSource: String) {
        self.targetPhrase = targetPhrase
        self.currentSource = currentSource
    }

    public func perform() async throws -> some IntentResult {
        let repo = GameDataRepository.shared
        if !targetPhrase.isEmpty {
            if let word = repo.allWords.first(where: { $0.phrase == targetPhrase }) {
                repo.completeLevel(Classic10000LevelsEngine.levelFromWord(word))
            }
        }

        let total = repo.allWords.count
        if total > 0 {
            var lastPick = repo.allWords[Int.random(in: 0 ..< total)]
            for _ in 0 ..< 4 {
                let candidate = repo.allWords[Int.random(in: 0 ..< total)]
                let diffSource = candidate.source != currentSource
                let unlearned = !repo.isLevelCompleted(candidate.phrase)
                if unlearned && diffSource {
                    lastPick = candidate
                    break
                }
                if unlearned {
                    lastPick = candidate
                }
            }
            let defaults = UserDefaults(suiteName: "group.com.eastlakestudio.luduan") ?? UserDefaults.standard
            defaults.set(lastPick.phrase, forKey: "widgetPinnedPhrase")
        }

        WidgetCenter.shared.reloadTimelines(ofKind: "IdiomWidget")
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
