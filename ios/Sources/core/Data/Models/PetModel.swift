import Foundation

/// 乘黄进化阶段
public enum PetEvolutionStage: String, Codable, CaseIterable, Comparable {
    case youth = "幼年乘黄"
    case ink = "墨香乘黄"
    case celestial = "凌云神黄"
    
    public var requiredCompletedLevels: Int {
        switch self {
        case .youth: return 0
        case .ink: return 3
        case .celestial: return 6
        }
    }
    
    public var description: String {
        switch self {
        case .youth: return "初降凡尘的神兽幼崽，憨态可掬，伴你开启诗词之旅。"
        case .ink: return "浸润千载墨香，身披文光，可为你指点字里行间的谜题。"
        case .celestial: return "头生金角，脚踏祥云，手握文渊卷轴，化身终极圣兽。"
        }
    }
    
    public var iconSymbol: String {
        switch self {
        case .youth: return "sparkles"
        case .ink: return "flame.fill"
        case .celestial: return "crown.fill"
        }
    }
    
    public static func < (lhs: PetEvolutionStage, rhs: PetEvolutionStage) -> Bool {
        return lhs.requiredCompletedLevels < rhs.requiredCompletedLevels
    }
}

/// 乘黄状态（纯关卡数驱动，无积分机制）
public struct PetModel: Codable, Equatable {
    public var completedLevelCount: Int
    
    public init(completedLevelCount: Int = 0) {
        self.completedLevelCount = completedLevelCount
    }
    
    /// 当前进化阶段
    public var currentStage: PetEvolutionStage {
        if completedLevelCount >= PetEvolutionStage.celestial.requiredCompletedLevels {
            return .celestial
        } else if completedLevelCount >= PetEvolutionStage.ink.requiredCompletedLevels {
            return .ink
        } else {
            return .youth
        }
    }
    
    /// 距离下一阶段所需破关数
    public var nextStageRequiredLevels: Int? {
        switch currentStage {
        case .youth: return PetEvolutionStage.ink.requiredCompletedLevels
        case .ink: return PetEvolutionStage.celestial.requiredCompletedLevels
        case .celestial: return nil
        }
    }
    
    /// 随性伴学励志语录
    public var randomQuote: String {
        let quotes = [
            "骑乘神兽，穿越千年的字里行间。",
            "读书破万卷，下笔如有神！",
            "关关雎鸠，在河之洲。今天你解开了几字名句？",
            "长风破浪会有时，直挂云帆济沧海！",
            "字词之中有乾坤，乘黄随你破万难。"
        ]
        return quotes[abs(completedLevelCount) % quotes.count]
    }
}
