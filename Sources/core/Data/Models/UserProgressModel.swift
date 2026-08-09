import Foundation

public struct UserProgressModel: Codable, Equatable {
    public var completedLevelIds: Set<String>
    public var learnedPhrases: Set<String>
    public var unlockedBadgeIds: Set<String>
    public var totalScore: Int
    public var lastActiveTheme: CultureTheme
    public var freshReplayThemeIds: Set<String>

    public init(
        completedLevelIds: Set<String> = [],
        learnedPhrases: Set<String> = [],
        unlockedBadgeIds: Set<String> = [],
        totalScore: Int = 0,
        lastActiveTheme: CultureTheme = .shihan,
        freshReplayThemeIds: Set<String> = []
    ) {
        self.completedLevelIds = completedLevelIds
        self.learnedPhrases = learnedPhrases
        self.unlockedBadgeIds = unlockedBadgeIds
        self.totalScore = totalScore
        self.lastActiveTheme = lastActiveTheme
        self.freshReplayThemeIds = freshReplayThemeIds
    }

    private enum CodingKeys: String, CodingKey {
        case completedLevelIds, learnedPhrases, unlockedBadgeIds, totalScore, lastActiveTheme, freshReplayThemeIds
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        completedLevelIds = try c.decodeIfPresent(Set<String>.self, forKey: .completedLevelIds) ?? []
        learnedPhrases = try c.decodeIfPresent(Set<String>.self, forKey: .learnedPhrases) ?? []
        unlockedBadgeIds = try c.decodeIfPresent(Set<String>.self, forKey: .unlockedBadgeIds) ?? []
        totalScore = try c.decodeIfPresent(Int.self, forKey: .totalScore) ?? 0
        lastActiveTheme = try c.decodeIfPresent(CultureTheme.self, forKey: .lastActiveTheme) ?? .shihan
        freshReplayThemeIds = try c.decodeIfPresent(Set<String>.self, forKey: .freshReplayThemeIds) ?? []
    }
}
