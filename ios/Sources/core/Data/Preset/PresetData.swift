import Foundation

/// 预置数据：勋章一律从 badges.json（shared/data 单一数据源）加载。
/// v1.3.0：移除 64 个历史硬编码勋章（与 JSON 新 id 体系重复，且含已删除人物）。
enum PresetData {

    public static var defaultBadges: [BadgeModel] {
        if let data = GameDataRepository.loadJSONData(named: "badges"),
           let decoded = try? JSONDecoder().decode([BadgeModel].self, from: data) {
            return decoded
        }
        return []
    }
}
