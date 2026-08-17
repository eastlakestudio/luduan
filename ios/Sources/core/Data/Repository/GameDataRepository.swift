import Foundation
import Combine

/// 确定性伪随机数生成器（LCG 算法）：保证基于种子生成完全稳定且充分离散打乱的序列
public struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    public init(seed: Int) {
        let positiveSeed = UInt64(bitPattern: Int64(seed == 0 ? 123456789 : abs(seed)))
        self.state = positiveSeed == 0 ? 987654321 : positiveSeed
    }
    public mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

/// 游戏核心数据仓库
public final class GameDataRepository: ObservableObject {
    public static let shared = GameDataRepository()
    
    @Published public private(set) var userProgress: UserProgressModel
    @Published public private(set) var badges: [BadgeModel] = []
    @Published public var activeBadge: BadgeModel?
    
    public private(set) var allWords: [ClassicalSeedItem] = []
    public private(set) var badgeRanges: [String: Set<String>] = [:]
    
    private let userProgressKey = "luDuanUserProgress_v2"
    private static let legacyProgressKeys = ["luDuanUserProgress_v2", "luDuanUserProgress_v1", "luDuanUserProgress", "userProgress", "user_progress"]
    private static let appGroupSuiteName = "group.com.eastlakestudio.luduan"
    
    private var sharedUserDefaults: UserDefaults? {
        UserDefaults(suiteName: GameDataRepository.appGroupSuiteName)
    }
    
    private static var documentsProgressURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("luduan_user_progress.json")
    }
    
    public init() {
        self.userProgress = GameDataRepository.loadMergedProgressFromAllSources()
        
        self.badges = PresetData.defaultBadges
        let validIds = Set(self.badges.map { $0.id })
        self.userProgress.unlockedBadgeIds = self.userProgress.unlockedBadgeIds.intersection(validIds)
        
        saveProgress()
        loadWordsAndBadgeRanges()
    }
    
    public static func loadMergedProgressFromAllSources() -> UserProgressModel {
        var merged = UserProgressModel()
        let sharedDefaults = UserDefaults(suiteName: GameDataRepository.appGroupSuiteName)
        
        // 1. Documents 本地持久化物理文件（原子性保障）
        if let fileURL = documentsProgressURL,
           let fileData = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode(UserProgressModel.self, from: fileData) {
            merged.merge(with: decoded)
        }
        
        // 2. App Group Shared UserDefaults（跨组件与主 App 共享）
        for key in legacyProgressKeys {
            if let data = sharedDefaults?.data(forKey: key),
               let decoded = try? JSONDecoder().decode(UserProgressModel.self, from: data) {
                merged.merge(with: decoded)
            }
        }
        
        // 3. Keychain 硬件级钥匙串（跨版本升级、覆盖安装与卸载重装保障）
        for key in legacyProgressKeys {
            if let data = KeychainStore.load(key: key),
               let decoded = try? JSONDecoder().decode(UserProgressModel.self, from: data) {
                merged.merge(with: decoded)
            }
        }
        
        // 4. Standard UserDefaults 本地沙盒缓存
        for key in legacyProgressKeys {
            if let data = UserDefaults.standard.data(forKey: key),
               let decoded = try? JSONDecoder().decode(UserProgressModel.self, from: data) {
                merged.merge(with: decoded)
            }
        }
        
        return merged
    }
    
    public func syncFromAppGroup() {
        let currentLoaded = GameDataRepository.loadMergedProgressFromAllSources()
        if currentLoaded.learnedPhrases.count > self.userProgress.learnedPhrases.count ||
           currentLoaded.unlockedBadgeIds.count > self.userProgress.unlockedBadgeIds.count {
            self.userProgress.merge(with: currentLoaded)
            saveProgress()
        }
    }
    
    private func loadWordsAndBadgeRanges() {
        if let data = GameDataRepository.loadJSONData(named: "words"),
           let items = try? JSONDecoder().decode([ClassicalSeedItem].self, from: data) {
            self.allWords = items
        }
        
        var idxToPhrase = [Int: String]()
        for (i, word) in self.allWords.enumerated() {
            let index = word.idx ?? i
            idxToPhrase[index] = word.phrase
        }
        
        var badgeWordMap = [String: [Int]]()
        if let data = GameDataRepository.loadJSONData(named: "badge_word_map"),
           let map = try? JSONDecoder().decode([String: [Int]].self, from: data) {
            badgeWordMap = map
        }
        
        for badge in badges {
            var phrases = Set<String>()
            if let indices = badgeWordMap[badge.id] {
                for idx in indices {
                    if let phrase = idxToPhrase[idx] {
                        phrases.insert(phrase)
                    }
                }
            }
            // v1.3.0: 移除 source+story 文本兜底（story 注释误关联），
            // 词池一律以 badge_word_map 索引为准（与 Android 一致）
            badgeRanges[badge.id] = phrases
        }
    }

    public static func loadJSONData(named name: String) -> Data? {
        if let url = Bundle.main.url(forResource: name, withExtension: "json") {
            if let data = try? Data(contentsOf: url) { return data }
        }
        if let url = Bundle.module.url(forResource: name, withExtension: "json") {
            if let data = try? Data(contentsOf: url) { return data }
        }
        if let url = Bundle(for: GameDataRepository.self).url(forResource: name, withExtension: "json") {
            if let data = try? Data(contentsOf: url) { return data }
        }
        return nil
    }

    public func setActiveBadge(_ badge: BadgeModel?) {
        self.activeBadge = badge
    }
    
    public func isLevelCompleted(_ phrase: String) -> Bool {
        return userProgress.learnedPhrases.contains(phrase)
    }
    
    public func completeLevel(_ level: LevelModel) {
        userProgress.learnedPhrases.insert(level.targetPhrase)
        userProgress.totalScore += 10
        
        if let badgeId = level.rewardBadgeId {
            userProgress.unlockedBadgeIds.insert(badgeId)
        }
        
        for badge in badges {
            if userProgress.unlockedBadgeIds.contains(badge.id) { continue }
            if let range = badgeRanges[badge.id], !range.isEmpty {
                if range.isSubset(of: userProgress.learnedPhrases) {
                    userProgress.unlockedBadgeIds.insert(badge.id)
                }
            }
        }
        saveProgress()
    }

    public func isBadgeUnlocked(_ badgeId: String) -> Bool {
        return userProgress.unlockedBadgeIds.contains(badgeId)
    }
    
    public func badgeProgressInfo(_ badge: BadgeModel) -> (completed: Int, total: Int, ratio: Double) {
        let range = badgeRanges[badge.id] ?? []
        let total = max(1, range.count)
        let completed = range.intersection(userProgress.learnedPhrases).count
        return (completed, range.count, Double(completed) / Double(total))
    }
    
    public func themeProgressInfo(theme: CultureTheme) -> (completed: Int, total: Int, ratio: Double) {
        let tWords = themeWords(for: theme)
        if tWords.isEmpty { return (0, 1, 0.0) }
        let c = tWords.filter { userProgress.learnedPhrases.contains($0.phrase) }.count
        return (c, tWords.count, Double(c)/Double(tWords.count))
    }

    private var cachedBadgeWords: [String: [ClassicalSeedItem]] = [:]
    private var cachedThemeWords: [CultureTheme: [ClassicalSeedItem]] = [:]
    
    public func badgeWords(for badgeId: String) -> [ClassicalSeedItem] {
        if let cached = cachedBadgeWords[badgeId] {
            return cached
        }
        let range = badgeRanges[badgeId] ?? []
        var words = allWords.filter { range.contains($0.phrase) }
        var generator = SeededRandomNumberGenerator(seed: abs(badgeId.hashValue) &+ 773)
        words.shuffle(using: &generator)
        cachedBadgeWords[badgeId] = words
        return words
    }
    
    public func themeProgressInfo(for level: LevelModel) -> (currentIndex: Int, totalCount: Int) {
        if let badgeId = level.badgeId {
            let words = badgeWords(for: badgeId)
            let count = words.count
            let idx = words.firstIndex(where: { $0.phrase == level.targetPhrase }) ?? 0
            return (currentIndex: idx + 1, totalCount: max(1, count))
        } else {
            let words = themeWords(for: level.theme)
            let count = words.count
            let idx = words.firstIndex(where: { $0.phrase == level.targetPhrase }) ?? 0
            return (currentIndex: idx + 1, totalCount: max(1, count))
        }
    }

    public func themeWords(for theme: CultureTheme) -> [ClassicalSeedItem] {
        if let cached = cachedThemeWords[theme] {
            return cached
        }
        var rawWords = allWords.filter { word in
            switch theme {
            case .shijing:
                return word.source.contains("诗经")
            case .tangsong:
                return word.source.contains("唐") || word.source.contains("宋") || word.source.contains("词") || word.source.contains("李白") || word.source.contains("杜甫") || word.source.contains("王维") || word.source.contains("花间") || word.source.contains("诗")
            case .shihan:
                return !(word.source.contains("诗经") || word.source.contains("唐") || word.source.contains("宋") || word.source.contains("词") || word.source.contains("李白") || word.source.contains("杜甫") || word.source.contains("王维") || word.source.contains("花间") || word.source.contains("诗"))
            }
        }
        var generator = SeededRandomNumberGenerator(seed: abs(theme.rawValue.hashValue) &+ 317)
        rawWords.shuffle(using: &generator)
        cachedThemeWords[theme] = rawWords
        return rawWords
    }

    public func levelForBadge(_ badge: BadgeModel, skipCompleted: Bool = true) -> LevelModel? {
        let words = badgeWords(for: badge.id)
        let categoryName = badge.name
        
        if skipCompleted {
            if let w = words.first(where: { !userProgress.learnedPhrases.contains($0.phrase) }) {
                return Classic10000LevelsEngine.levelFromWord(w, categoryName: categoryName, badgeId: badge.id)
            }
        }
        if let first = words.first {
            return Classic10000LevelsEngine.levelFromWord(first, categoryName: categoryName, badgeId: badge.id)
        }
        return nil
    }

    public func nextLevelForBadge(_ badgeId: String, currentPhrase: String) -> LevelModel? {
        let words = badgeWords(for: badgeId)
        let badge = badges.first { $0.id == badgeId }
        let categoryName = badge?.name ?? ""
        
        if let currentIndex = words.firstIndex(where: { $0.phrase == currentPhrase }) {
            let remaining = words.suffix(from: currentIndex + 1)
            if let next = remaining.first(where: { !userProgress.learnedPhrases.contains($0.phrase) }) {
                return Classic10000LevelsEngine.levelFromWord(next, categoryName: categoryName, badgeId: badgeId)
            }
        }
        if let firstUnlearned = words.first(where: { !userProgress.learnedPhrases.contains($0.phrase) }) {
            return Classic10000LevelsEngine.levelFromWord(firstUnlearned, categoryName: categoryName, badgeId: badgeId)
        }
        // v1.3.0: 词池全部完成 → 返回 nil，由 UI 弹"本卷已全部完成"（不再 wrap 幽灵关卡）
        return nil
    }

    public func nextThemeLevel(after current: LevelModel) -> LevelModel? {
        if let badgeId = current.badgeId, let badge = badges.first(where: { $0.id == badgeId }) {
            let words = badgeWords(for: badgeId)
            guard let idx = words.firstIndex(where: { $0.phrase == current.targetPhrase }) else {
                return words.first.map { Classic10000LevelsEngine.levelFromWord($0, categoryName: badge.name, badgeId: badgeId) }
            }
            if idx + 1 < words.count {
                return Classic10000LevelsEngine.levelFromWord(words[idx + 1], categoryName: badge.name, badgeId: badgeId)
            }
            return nil
        } else {
            let words = themeWords(for: current.theme)
            guard let idx = words.firstIndex(where: { $0.phrase == current.targetPhrase }) else {
                return words.first.map { Classic10000LevelsEngine.levelFromWord($0) }
            }
            if idx + 1 < words.count {
                return Classic10000LevelsEngine.levelFromWord(words[idx + 1])
            }
            return nil
        }
    }

    public func previousLevel(before current: LevelModel) -> LevelModel? {
        if let badgeId = current.badgeId, let badge = badges.first(where: { $0.id == badgeId }) {
            let words = badgeWords(for: badgeId)
            guard let idx = words.firstIndex(where: { $0.phrase == current.targetPhrase }) else { return nil }
            if idx > 0 {
                return Classic10000LevelsEngine.levelFromWord(words[idx - 1], categoryName: badge.name, badgeId: badgeId)
            }
            return nil
        } else {
            let words = themeWords(for: current.theme)
            guard let idx = words.firstIndex(where: { $0.phrase == current.targetPhrase }) else { return nil }
            if idx > 0 {
                return Classic10000LevelsEngine.levelFromWord(words[idx - 1])
            }
            return nil
        }
    }

    public func nextLevel(after current: LevelModel) -> LevelModel? {
        if let bid = current.badgeId {
            return nextLevelForBadge(bid, currentPhrase: current.targetPhrase)
        }
        if let next = nextThemeLevel(after: current) {
            return next
        }
        
        if let idx = allWords.firstIndex(where: { $0.phrase == current.targetPhrase }) {
            let remaining = allWords.suffix(from: idx + 1)
            if let w = remaining.first(where: { !userProgress.learnedPhrases.contains($0.phrase) }) {
                return Classic10000LevelsEngine.levelFromWord(w)
            }
        }
        if let w = allWords.first(where: { !userProgress.learnedPhrases.contains($0.phrase) }) {
            return Classic10000LevelsEngine.levelFromWord(w)
        }
        if let first = allWords.first {
            return Classic10000LevelsEngine.levelFromWord(first)
        }
        return nil
    }

    public func level(withId id: String) -> LevelModel? {
        if let word = allWords.first(where: { "level_\(abs($0.phrase.hashValue))" == id }) {
            return Classic10000LevelsEngine.levelFromWord(word)
        }
        return nil
    }

    public func levelsForBadge(_ badge: BadgeModel) -> [LevelModel] {
        return badgeWords(for: badge.id).map {
            Classic10000LevelsEngine.levelFromWord($0, categoryName: badge.name, badgeId: badge.id)
        }
    }

    public func nextUncompletedLevel(for theme: CultureTheme) -> LevelModel? {
        let tWords = themeWords(for: theme)
        let isFreshPlay = userProgress.freshReplayThemeIds.contains(theme.rawValue)
        if isFreshPlay {
            if let word = tWords.first {
                return Classic10000LevelsEngine.levelFromWord(word)
            }
        } else {
            if let word = tWords.first(where: { !userProgress.learnedPhrases.contains($0.phrase) }) {
                return Classic10000LevelsEngine.levelFromWord(word)
            }
        }
        return nil
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
            // 1. App Group Shared Defaults
            sharedUserDefaults?.set(encoded, forKey: userProgressKey)
            
            // 2. Keychain 硬件级安全持久化（防卸载与防系统升级重置）
            KeychainStore.save(key: userProgressKey, data: encoded)
            
            // 3. Standard UserDefaults
            UserDefaults.standard.set(encoded, forKey: userProgressKey)
            
            // 4. Documents 物理文件原子写入（防崩溃/防沙盒损坏）
            if let fileURL = Self.documentsProgressURL {
                try? encoded.write(to: fileURL, options: .atomicWrite)
            }
        }
    }
    
    public func toggleFreshReplayMode(for themeKey: String) {
        if userProgress.freshReplayThemeIds.contains(themeKey) {
            userProgress.freshReplayThemeIds.remove(themeKey)
        } else {
            userProgress.freshReplayThemeIds.insert(themeKey)
        }
        saveProgress()
    }
    
    public func isThemeInFreshPlay(_ themeKey: String) -> Bool {
        return userProgress.freshReplayThemeIds.contains(themeKey)
    }
}
