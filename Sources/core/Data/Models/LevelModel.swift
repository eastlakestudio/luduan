import Foundation

/// 中国历史朝代
public enum Dynasty: String, Codable, CaseIterable, Identifiable {
    case zhou = "周朝"
    case qin = "秦朝"
    case han = "两汉"
    case tang = "唐朝"
    case song = "宋朝"
    case ming = "明朝"
    case qing = "清朝"
    
    public var id: String { rawValue }
}

/// 文化主题分类
public enum CultureTheme: String, Codable, CaseIterable, Identifiable {
    case shihan = "史汉典故"
    case shijing = "诗经风雅"
    case tangsong = "唐诗宋词"
    
    public var id: String { rawValue }
    
    public var subtitle: String {
        switch self {
        case .shihan: return "《史记》《汉书》《战国策》成语典故"
        case .shijing: return "《诗经》风雅颂名句与生僻字赏析"
        case .tangsong: return "《唐诗三百首》与宋词名篇选字"
        }
    }
    
    public var iconName: String {
        switch self {
        case .shihan: return "book.closed.fill"
        case .shijing: return "leaf.fill"
        case .tangsong: return "scroll.fill"
        }
    }
    
    public var academicGradeLabel: String {
        switch self {
        case .shihan: return "初中文言典故"
        case .shijing: return "小学风雅启蒙"
        case .tangsong: return "高中宋词名篇"
        }
    }
    
    public var officialRankLabel: String {
        switch self {
        case .shihan: return "进士红袍功名"
        case .shijing: return "秀才童生功名"
        case .tangsong: return "翰林学士功名"
        }
    }
}

/// 三大通关主模式
public enum ThemeDimension: String, Codable, CaseIterable, Identifiable {
    case academic = "学阶功名"
    case classics = "典籍名篇"
    case practical = "处世修养"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .academic: return "graduationcap.fill"
        case .classics: return "book.fill"
        case .practical: return "heart.fill"
        }
    }
}

/// 学阶功名六大层次
public enum AcademicRank: String, Codable, CaseIterable, Identifiable {
    case tongSheng = "童生"
    case xiuCai = "秀才"
    case juRen = "举人"
    case jinShi = "进士"
    case hanLin = "翰林"
    case shouFu = "首辅"
    
    public var id: String { rawValue }
    
    public var curriculumMapping: String {
        switch self {
        case .tongSheng: return "小学语文 1-6年级常用字"
        case .xiuCai: return "初中语文 / 中考必考"
        case .juRen: return "高中语文 / 高考冲刺"
        case .jinShi: return "大学汉语 / 考研常识"
        case .hanLin: return "硕士深造 / 史书经学"
        case .shouFu: return "博士学者 / 帝师绝学"
        }
    }
    
    public var badgeSealText: String {
        switch self {
        case .tongSheng: return "童生\n启蒙"
        case .xiuCai: return "秀才\n中考"
        case .juRen: return "举人\n高考"
        case .jinShi: return "进士\n考研"
        case .hanLin: return "翰林\n学者"
        case .shouFu: return "首辅\n帝师"
        }
    }
    
    /// 明朝风骨童生/秀才/官服卡通形象资源名
    public var mingDynastyCartoonImageName: String {
        switch self {
        case .tongSheng: return "badge_academic_tongsheng"
        case .xiuCai: return "badge_academic_xiucai"
        case .juRen: return "badge_academic_juren"
        case .jinShi: return "badge_academic_jinshi"
        case .hanLin: return "badge_academic_hanlin"
        case .shouFu: return "badge_academic_shoufu"
        }
    }
}

/// 处世修养七大古汉语主题
public enum PracticalTheme: String, Codable, CaseIterable, Identifiable {
    case xiushen = "《修身立德》"
    case qijia = "《齐家修业》"
    case jiaoyou = "《处世交友》"
    case huozhi = "《计然货殖》"
    case bingfa = "《兵法韬略》"
    case zhiguo = "《治国理政》"
    case pingtianxia = "《平天下怀》"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .xiushen: return "person.fill.checkmark"
        case .qijia: return "house.fill"
        case .jiaoyou: return "person.2.fill"
        case .huozhi: return "yensign.circle.fill"
        case .bingfa: return "shield.fill"
        case .zhiguo: return "building.columns.fill"
        case .pingtianxia: return "globe.asia.australia.fill"
        }
    }
}

/// 关卡模型
public struct LevelModel: Identifiable, Codable, Equatable {
    public let id: String
    public let theme: CultureTheme
    public let title: String
    public let categoryName: String
    public let targetPhrase: String
    public let tileMatrix: [String]
    public let annotation: String
    public let story: String
    public let source: String
    public let rewardBadgeId: String?
    
    public var displayCategoryName: String {
        categoryName.isEmpty ? theme.rawValue : categoryName
    }
    
    public init(
        id: String,
        theme: CultureTheme,
        title: String,
        categoryName: String = "",
        targetPhrase: String,
        tileMatrix: [String],
        annotation: String,
        story: String,
        source: String,
        rewardBadgeId: String? = nil
    ) {
        self.id = id
        self.theme = theme
        self.title = title
        self.categoryName = categoryName
        self.targetPhrase = targetPhrase
        self.tileMatrix = tileMatrix
        self.annotation = annotation
        self.story = story
        self.source = source
        self.rewardBadgeId = rewardBadgeId
    }
}
