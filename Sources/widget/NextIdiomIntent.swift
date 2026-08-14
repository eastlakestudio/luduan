import AppIntents
import WidgetKit
import Foundation

struct NextIdiomIntent: AppIntent {
    static var title: LocalizedStringResource = "已学"
    static var description = IntentDescription("标记当前成语为已学，随机切换到不同典籍的下一个未学成语。")

    @Parameter(title: "Level ID")
    var levelId: String

    @Parameter(title: "Current Source")
    var currentSource: String

    init() {}

    init(levelId: String, currentSource: String) {
        self.levelId = levelId
        self.currentSource = currentSource
    }

    func perform() async throws -> some IntentResult {
        let repo = GameDataRepository.shared

        // 1. 标记当前词已学
        if let level = repo.levels.first(where: { $0.id == levelId }) {
            repo.completeLevel(level)
        }

        // 2. 随机选下一个词：生成随机序号，已学则最多再试 3 次（共 4 次）；四次都已学用最后一个
        let total = repo.levels.count
        var lastPick = repo.levels[Int.random(in: 0 ..< total)]
        for _ in 0 ..< 4 {
            let candidate = repo.levels[Int.random(in: 0 ..< total)]
            let diffSource = candidate.source != currentSource
            let unlearned = !repo.isLevelCompleted(candidate.id)
            if unlearned && diffSource {
                lastPick = candidate
                break
            }
            if unlearned {
                lastPick = candidate
            }
        }

        // 3. 将下一词索引写入 SharedDefaults，供 Timeline 优先展示
        let defaults = UserDefaults(suiteName: "group.com.eastlakestudio.luduan")
        if let idx = repo.levels.firstIndex(where: { $0.id == lastPick.id }) {
            defaults?.set(idx, forKey: "widgetPinnedIndex")
        }

        WidgetCenter.shared.reloadTimelines(ofKind: "IdiomWidget")
        return .result()
    }
}
