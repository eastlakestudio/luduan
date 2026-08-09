import Foundation
import Combine

/// 游戏核心数据仓库
public final class GameDataRepository: ObservableObject {
    public static let shared = GameDataRepository()
    
    @Published public private(set) var userProgress: UserProgressModel
    @Published public private(set) var badges: [BadgeModel] = []
    @Published public var activeBadge: BadgeModel?
    
    public func setActiveBadge(_ badge: BadgeModel?) {
        self.activeBadge = badge
    }
    
    private var completedCountCache: [String: Int] = [:]
    
    private let userProgressKey = "luDuanUserProgress_v2"
    
    public init() {
        if let kcData = KeychainStore.load(key: userProgressKey),
           let decoded = try? JSONDecoder().decode(UserProgressModel.self, from: kcData) {
            self.userProgress = decoded
        } else if let udData = UserDefaults.standard.data(forKey: userProgressKey),
                  let decoded = try? JSONDecoder().decode(UserProgressModel.self, from: udData) {
            self.userProgress = decoded
            saveProgress()
        } else {
            self.userProgress = UserProgressModel()
        }
        migrateLegacyLevelProgress()
        self.badges = PresetData.defaultBadges
        let validIds = Set(self.badges.map { $0.id })
        userProgress.unlockedBadgeIds = userProgress.unlockedBadgeIds.intersection(validIds)
    }

    private func migrateLegacyLevelProgress() {
        guard userProgress.learnedPhrases.isEmpty, !userProgress.completedLevelIds.isEmpty else { return }
        for levelId in userProgress.completedLevelIds {
            if let phrase = phrase(forLevelId: levelId) {
                userProgress.learnedPhrases.insert(phrase)
            }
        }
        if !userProgress.learnedPhrases.isEmpty { saveProgress() }
    }

    private func phrase(forLevelId levelId: String) -> String? {
        guard levelId.hasPrefix("level_"), let n = Int(levelId.dropFirst("level_".count)) else { return nil }
        return Classic10000LevelsEngine.level(at: n - 1).targetPhrase
    }
    
    private static let cachedLevels: [LevelModel] = (0..<10000).map { Classic10000LevelsEngine.level(at: $0) }
    
    private static let themeBooksMapping: [String: [String]] = {
        guard let url = Bundle.module.url(forResource: "theme_books", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let mapping = try? JSONDecoder().decode([String: [String]].self, from: data) else {
            return [:]
        }
        return mapping
    }()
    
    private struct BookPhraseItemDecoder: Decodable {
        let phrase: String
    }
    
    private static let bookPhrasesMapping: [String: [String]] = {
        guard let url = Bundle.module.url(forResource: "book_phrases", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let dict = try? JSONDecoder().decode([String: [BookPhraseItemDecoder]].self, from: data) else {
            return [:]
        }
        var res: [String: [String]] = [:]
        for (key, items) in dict {
            res[key] = items.map { $0.phrase }
        }
        return res
    }()
    
    private static let academicPhrasesMapping: [String: [String]] = {
        guard let url = Bundle.module.url(forResource: "academic_phrases", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let dict = try? JSONDecoder().decode([String: [String]].self, from: data) else {
            return [:]
        }
        return dict
    }()
    
    /// 获取某部典籍收录的所有去重词汇名句
    public func uniquePhrases(forBook bookKey: String) -> [String] {
        return GameDataRepository.bookPhrasesMapping[bookKey] ?? []
    }
    
    /// 获取某部典籍的去重词汇完成进度 (已完成词数, 总词数, 比例 0.0~1.0)
    public func bookProgressInfo(forBook bookKey: String) -> (completed: Int, total: Int, ratio: Double) {
        let phrases = uniquePhrases(forBook: bookKey)
        guard !phrases.isEmpty else { return (0, 1, 0.0) }
        let completed = phrases.filter { userProgress.learnedPhrases.contains($0) }.count
        let ratio = Double(completed) / Double(phrases.count)
        return (completed, phrases.count, min(1.0, max(0.0, ratio)))
    }
    
    /// 获取【功名学阶】勋章按现代教学词频与独立词库统计的进度 (打破书籍限制)
    public func academicProgressInfo(_ badge: BadgeModel) -> (completed: Int, total: Int, ratio: Double) {
        let phrases = GameDataRepository.academicPhrasesMapping[badge.id] ?? []
        guard !phrases.isEmpty else {
            let bLevels = levelsForBadge(badge)
            let totalPhrasesSet = Set(bLevels.map { $0.targetPhrase })
            guard !totalPhrasesSet.isEmpty else { return (0, 1, 0.0) }
            let completedCount = totalPhrasesSet.filter { userProgress.learnedPhrases.contains($0) }.count
            let ratio = Double(completedCount) / Double(totalPhrasesSet.count)
            return (completedCount, totalPhrasesSet.count, min(1.0, max(0.0, ratio)))
        }
        let completedCount = phrases.filter { userProgress.learnedPhrases.contains($0) }.count
        let ratio = Double(completedCount) / Double(phrases.count)
        return (completedCount, phrases.count, min(1.0, max(0.0, ratio)))
    }
    
    /// 获取某个勋章/主题的去重词条统计完成进度
    public func badgeProgressInfo(_ badge: BadgeModel) -> (completed: Int, total: Int, ratio: Double) {
        if badge.category == .academic {
            return academicProgressInfo(badge)
        }
        
        let bookKeys = GameDataRepository.themeBooksMapping[badge.id] ?? []
        if bookKeys.isEmpty {
            let bLevels = levelsForBadge(badge)
            let totalPhrasesSet = Set(bLevels.map { $0.targetPhrase })
            guard !totalPhrasesSet.isEmpty else { return (0, 1, 0.0) }
            let completedCount = totalPhrasesSet.filter { userProgress.learnedPhrases.contains($0) }.count
            let ratio = Double(completedCount) / Double(totalPhrasesSet.count)
            return (completedCount, totalPhrasesSet.count, min(1.0, max(0.0, ratio)))
        }
        
        var totalPhrasesSet = Set<String>()
        for key in bookKeys {
            totalPhrasesSet.formUnion(uniquePhrases(forBook: key))
        }
        guard !totalPhrasesSet.isEmpty else { return (0, 1, 0.0) }
        let completedCount = totalPhrasesSet.filter { userProgress.learnedPhrases.contains($0) }.count
        let ratio = Double(completedCount) / Double(totalPhrasesSet.count)
        return (completedCount, totalPhrasesSet.count, min(1.0, max(0.0, ratio)))
    }
    
    /// 获取处世修养主题的去重词条统计完成进度
    public func practicalThemeProgressInfo(theme: PracticalTheme) -> (completed: Int, total: Int, ratio: Double) {
        let pLevels = levelsForCategory(theme.rawValue)
        let totalPhrasesSet = Set(pLevels.map { $0.targetPhrase })
        guard !totalPhrasesSet.isEmpty else { return (0, 1, 0.0) }
        let completedCount = totalPhrasesSet.filter { userProgress.learnedPhrases.contains($0) }.count
        let ratio = Double(completedCount) / Double(totalPhrasesSet.count)
        return (completedCount, totalPhrasesSet.count, min(1.0, max(0.0, ratio)))
    }
    
    public var levels: [LevelModel] {
        return GameDataRepository.cachedLevels
    }
    
    public func isLevelCompleted(_ levelId: String) -> Bool {
        return userProgress.completedLevelIds.contains(levelId)
    }
    
    public func nextUncompletedLevel(for theme: CultureTheme) -> LevelModel? {
        let themeLevels = themeLevels(for: theme)
        return themeLevels.first { !isLevelCompleted($0.id) } ?? themeLevels.first
    }
    
    public func nextSequentialLevel(after current: LevelModel) -> LevelModel? {
        if let idx = levelIndex(from: current.id), idx + 1 < levels.count {
            return levels[idx + 1]
        }
        return nil
    }
    
    private func levelIndex(from levelId: String) -> Int? {
        guard levelId.hasPrefix("level_"), let num = Int(levelId.dropFirst(6)) else { return nil }
        return num - 1
    }
    
    public func levelIndexInfo(for level: LevelModel) -> (index: Int, total: Int) {
        if let idx = levelIndex(from: level.id) {
            return (idx + 1, levels.count)
        }
        return (1, levels.count)
    }
    
    public func levelTitleName(for level: LevelModel) -> String {
        return level.title
    }
    
    private var themeLevelsCache: [CultureTheme: [LevelModel]] = [:]
    private var badgeLevelsCache: [String: [LevelModel]] = [:]
    private var categoryLevelsCache: [String: [LevelModel]] = [:]
    
    public func themeLevels(for theme: CultureTheme) -> [LevelModel] {
        if let cached = themeLevelsCache[theme] {
            return cached
        }
        let filtered = levels.filter { $0.theme == theme }
        themeLevelsCache[theme] = filtered
        return filtered
    }
    
    private func keywords(for bookKey: String) -> [String] {
        switch bookKey {
        case "shiji", "shihan": return ["史记", "汉书", "战国策", "资治通鉴", "三国志", "史籍"]
        case "shijing": return ["诗经", "周南", "秦风", "邶风", "卫风", "小雅", "大雅", "国风"]
        case "lunyu": return ["论语"]
        case "daodejing": return ["道德经", "老子"]
        case "mengzi": return ["孟子"]
        case "tangsong": return ["唐诗", "宋词", "诗包", "词包", "律诗", "绝句", "李白", "杜甫", "苏轼", "辛弃疾", "白居易", "李清照", "欧阳修", "屈原"]
        case "hongloumeng": return ["红楼梦"]
        case "xiyouji": return ["西游记"]
        case "caigentan": return ["菜根谭"]
        case "chuanxilu": return ["传习录"]
        case "yanshijiaxun": return ["颜氏家训"]
        case "zengguofanjiashu": return ["曾国藩家书"]
        case "xiaochuangyouji": return ["小窗幽记"]
        case "zhongyong": return ["中庸", "大学"]
        case "chunqiu": return ["春秋", "左传"]
        case "guoyu": return ["国语"]
        default: return [bookKey]
        }
    }
    
    public func themeProgressInfo(for level: LevelModel) -> (currentIndex: Int, totalCount: Int, completedCount: Int) {
        let tLevels = themeLevels(for: level.theme)
        let total = tLevels.count > 0 ? tLevels.count : 1
        let idx = (tLevels.firstIndex(where: { $0.id == level.id }) ?? 0) + 1
        let completed = tLevels.filter { isLevelCompleted($0.id) }.count
        return (idx, total, completed)
    }
    
    public func previousLevel(before current: LevelModel) -> LevelModel? {
        let tLevels = themeLevels(for: current.theme)
        if let idx = tLevels.firstIndex(where: { $0.id == current.id }), idx > 0 {
            return tLevels[idx - 1]
        }
        if let globalIdx = levelIndex(from: current.id), globalIdx > 0 {
            return levels[globalIdx - 1]
        }
        return nil
    }

    public func levelsForBadge(_ badge: BadgeModel) -> [LevelModel] {
        if let cached = badgeLevelsCache[badge.id] {
            return cached
        }
        if badge.category == .academic, let targetPhrases = GameDataRepository.academicPhrasesMapping[badge.id], !targetPhrases.isEmpty {
            let matching = levels.filter { targetPhrases.contains($0.targetPhrase) }
            let result = matching.isEmpty ? levels : matching
            badgeLevelsCache[badge.id] = result
            return result
        }
        
        let allowedBookKeys = GameDataRepository.themeBooksMapping[badge.id] ?? []
        let searchKeys = allowedBookKeys.flatMap { keywords(for: $0) }
        
        let cleanBadgeName = badge.name.replacingOccurrences(of: "《", with: "").replacingOccurrences(of: "》", with: "").replacingOccurrences(of: "章", with: "").replacingOccurrences(of: "印", with: "")
        
        let allKeywords = searchKeys + [cleanBadgeName]
        
        let matching = levels.filter { level in
            allKeywords.contains(where: { kw in
                level.source.contains(kw) || level.annotation.contains(kw) || level.story.contains(kw)
            })
        }
        let result = matching.isEmpty ? levelsForCategory(badge.name) : matching
        badgeLevelsCache[badge.id] = result
        return result
    }

    public func levelsForCategory(_ categoryName: String) -> [LevelModel] {
        if let cached = categoryLevelsCache[categoryName] {
            return cached
        }
        let cleanName = categoryName.replacingOccurrences(of: "《", with: "").replacingOccurrences(of: "》", with: "").replacingOccurrences(of: "章", with: "").replacingOccurrences(of: "印", with: "")
        let filtered = levels.filter { $0.source.contains(cleanName) || $0.categoryName.contains(cleanName) || $0.story.contains(cleanName) }
        let result = filtered.isEmpty ? levels : filtered
        categoryLevelsCache[categoryName] = result
        return result
    }

    public func nextThemeLevel(after current: LevelModel) -> LevelModel? {
        let tLevels = themeLevels(for: current.theme)
        let isFreshPlay = isThemeInFreshPlay(current.theme.rawValue) || isThemeInFreshPlay(current.categoryName)
        if let idx = tLevels.firstIndex(where: { $0.id == current.id }) {
            let remaining = tLevels.suffix(from: idx + 1)
            if isFreshPlay {
                return remaining.first
            } else {
                return remaining.first(where: { !isLevelCompleted($0.id) }) ?? remaining.first
            }
        }
        return nextSequentialLevel(after: current)
    }
    
    public func nextLevel(after current: LevelModel) -> LevelModel? {
        let isFreshPlay = isThemeInFreshPlay(current.theme.rawValue) || isThemeInFreshPlay(current.categoryName)
        if isFreshPlay, let idx = themeLevels(for: current.theme).firstIndex(where: { $0.id == current.id }) {
            return themeLevels(for: current.theme).suffix(from: idx + 1).first
        }
        if let startIdx = levelIndex(from: current.id) {
            for i in (startIdx + 1)..<10000 {
                let candidate = Classic10000LevelsEngine.level(at: i)
                if !userProgress.learnedPhrases.contains(candidate.targetPhrase) {
                    return candidate
                }
            }
        }
        for i in 0..<10000 {
            let candidate = Classic10000LevelsEngine.level(at: i)
            if !userProgress.learnedPhrases.contains(candidate.targetPhrase) {
                return candidate
            }
        }
        return Classic10000LevelsEngine.level(at: 0)
    }
    
    public func isThemeInFreshPlay(_ themeKey: String) -> Bool {
        return userProgress.freshReplayThemeIds.contains(themeKey)
    }

    public func toggleFreshReplayMode(for themeKey: String) {
        if userProgress.freshReplayThemeIds.contains(themeKey) {
            userProgress.freshReplayThemeIds.remove(themeKey)
        } else {
            userProgress.freshReplayThemeIds.insert(themeKey)
        }
        saveProgress()
    }
    
    public func completedCount(for levels: [LevelModel], key: String) -> Int {
        if let cached = completedCountCache[key] {
            return cached
        }
        let count = levels.filter { isLevelCompleted($0.id) }.count
        completedCountCache[key] = count
        return count
    }
    
    public func completeLevel(_ level: LevelModel) {
        completedCountCache.removeAll()
        userProgress.completedLevelIds.insert(level.id)
        userProgress.learnedPhrases.insert(level.targetPhrase)
        userProgress.totalScore += 10
        
        // 跨主题同词全域同步完成
        for l in GameDataRepository.cachedLevels where l.targetPhrase == level.targetPhrase {
            userProgress.completedLevelIds.insert(l.id)
        }
        
        if let badgeId = level.rewardBadgeId {
            userProgress.unlockedBadgeIds.insert(badgeId)
        }
        
        // 根据解锁关卡自动解锁相应成就勋章
        unlockMilestoneBadges()
        saveProgress()
    }
    
    private func unlockMilestoneBadges() {
        let count = userProgress.learnedPhrases.count
        let grouped = Dictionary(grouping: badges, by: { $0.category })
        for (_, catBadges) in grouped {
            let sorted = catBadges.sorted { $0.id < $1.id }
            let step = max(1, 200 / max(1, sorted.count))
            for (i, badge) in sorted.enumerated() {
                if count >= (i + 1) * step {
                    userProgress.unlockedBadgeIds.insert(badge.id)
                }
            }
        }
    }
    
    public func isBadgeUnlocked(_ badgeId: String) -> Bool {
        return userProgress.unlockedBadgeIds.contains(badgeId)
    }
    
    public func setActiveTheme(_ theme: CultureTheme) {
        userProgress.lastActiveTheme = theme
        saveProgress()
    }
    
    public func resetProgress() {
        userProgress = UserProgressModel()
        saveProgress()
    }
    
    private func saveProgress() {
        if let encoded = try? JSONEncoder().encode(userProgress) {
            KeychainStore.save(key: userProgressKey, data: encoded)
            UserDefaults.standard.set(encoded, forKey: userProgressKey)
        }
    }
}

/// 预置数据（勋章目录数据见 Resources/badges.json，代码仅负责加载与装配）
public struct PresetData {

    public static var defaultLevels: [LevelModel] {
        return (0..<1000).map { Classic10000LevelsEngine.level(at: $0) }
    }

    public static var defaultBadges: [BadgeModel] {
        guard let url = Bundle.module.url(forResource: "badges", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let badges = try? JSONDecoder().decode([BadgeModel].self, from: data) else {
            return []
        }
        return badges
    }
}
