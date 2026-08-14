import Foundation

/// 勋章 4 大主题分类
public enum BadgeCategory: String, Codable, CaseIterable, Identifiable {
    case character = "人物名将"
    case academic = "功名学阶"
    case classics = "典籍名篇"
    case practical = "处世修养"
    
    public var id: String { rawValue }
}

/// 勋章/印章卡片模型
public struct BadgeModel: Identifiable, Codable, Equatable {
    public let id: String
    public let name: String
    public let sealText: String
    public let category: BadgeCategory
    public let description: String
    public let requirementDescription: String
    public let imageName: String?
    public let dynasty: Dynasty?
    
    public init(
        id: String,
        name: String,
        sealText: String,
        category: BadgeCategory,
        description: String,
        requirementDescription: String,
        imageName: String? = nil,
        dynasty: Dynasty? = nil
    ) {
        self.id = id
        self.name = name
        self.sealText = sealText
        self.category = category
        self.description = description
        self.requirementDescription = requirementDescription
        self.imageName = imageName
        self.dynasty = dynasty
    }
}
