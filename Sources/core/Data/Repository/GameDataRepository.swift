import Foundation
import Combine

/// 游戏核心数据仓库
public final class GameDataRepository: ObservableObject {
    public static let shared = GameDataRepository()
    
    @Published public private(set) var userProgress: UserProgressModel
    @Published public private(set) var badges: [BadgeModel] = []
    
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
    
    public func themeLevels(for theme: CultureTheme) -> [LevelModel] {
        return levels.filter { $0.theme == theme }
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
    
    public func nextThemeLevel(after current: LevelModel) -> LevelModel? {
        let tLevels = themeLevels(for: current.theme)
        if let idx = tLevels.firstIndex(where: { $0.id == current.id }), idx + 1 < tLevels.count {
            return tLevels[idx + 1]
        }
        return nextSequentialLevel(after: current)
    }
    
    public func nextLevel(after current: LevelModel) -> LevelModel? {
        let tLevels = themeLevels(for: current.theme)
        if let idx = tLevels.firstIndex(where: { $0.id == current.id }), idx + 1 < tLevels.count {
            return tLevels[idx + 1]
        }
        if let globalIdx = levelIndex(from: current.id), globalIdx + 1 < levels.count {
            return levels[globalIdx + 1]
        }
        return levels.first(where: { !isLevelCompleted($0.id) }) ?? levels.first
    }
    
    public func completeLevel(_ level: LevelModel) {
        userProgress.completedLevelIds.insert(level.id)
        userProgress.learnedPhrases.insert(level.targetPhrase)
        userProgress.totalScore += 10
        
        if let badgeId = level.rewardBadgeId {
            userProgress.unlockedBadgeIds.insert(badgeId)
        }
        
        // 根据解锁关卡自动解锁相应成就勋章
        unlockMilestoneBadges()
        saveProgress()
    }
    
    private func unlockMilestoneBadges() {
        let count = userProgress.learnedPhrases.count
        for badge in badges {
            if let reqCount = extractRequirementCount(from: badge.id), count >= reqCount {
                userProgress.unlockedBadgeIds.insert(badge.id)
            }
        }
    }
    
    private func extractRequirementCount(from badgeId: String) -> Int? {
        if badgeId.hasPrefix("badge_char_") || badgeId.hasPrefix("badge_acad_") || badgeId.hasPrefix("badge_class_") || badgeId.hasPrefix("badge_prac_") {
            let components = badgeId.components(separatedBy: "_")
            if let last = components.last, let num = Int(last) {
                return num
            }
        }
        return nil
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
