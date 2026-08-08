import Foundation

public struct UserProgressModel: Codable, Equatable {
    public var completedLevelIds: Set<String>
    public var unlockedBadgeIds: Set<String>
    public var totalScore: Int
    public var lastActiveTheme: CultureTheme
    
    public init(
        completedLevelIds: Set<String> = [],
        unlockedBadgeIds: Set<String> = [],
        totalScore: Int = 0,
        lastActiveTheme: CultureTheme = .shihan
    ) {
        self.completedLevelIds = completedLevelIds
        self.unlockedBadgeIds = unlockedBadgeIds
        self.totalScore = totalScore
        self.lastActiveTheme = lastActiveTheme
    }
}
