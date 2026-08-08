import Foundation
import Combine

/// 游戏核心数据仓库
public final class GameDataRepository: ObservableObject {
    public static let shared = GameDataRepository()
    
    @Published public private(set) var userProgress: UserProgressModel
    @Published public private(set) var badges: [BadgeModel] = []
    
    private let userProgressKey = "HornedFoxUserProgress_v2"
    
    public init() {
        if let data = UserDefaults.standard.data(forKey: userProgressKey),
           let decoded = try? JSONDecoder().decode(UserProgressModel.self, from: data) {
            self.userProgress = decoded
        } else {
            self.userProgress = UserProgressModel()
        }
        
        self.badges = PresetData.defaultBadges
    }
    
    public var levels: [LevelModel] {
        return (0..<10000).map { Classic10000LevelsEngine.level(at: $0) }
    }
    
    public func isLevelCompleted(_ levelId: String) -> Bool {
        return userProgress.completedLevelIds.contains(levelId)
    }
    
    public func nextUncompletedLevel(for theme: CultureTheme) -> LevelModel? {
        let themeLevels = levels.filter { $0.theme == theme }
        return themeLevels.first { !isLevelCompleted($0.id) } ?? themeLevels.first
    }
    
    public func nextSequentialLevel(after current: LevelModel) -> LevelModel? {
        if let idx = levels.firstIndex(where: { $0.id == current.id }), idx + 1 < levels.count {
            return levels[idx + 1]
        }
        return nil
    }
    
    public func levelIndexInfo(for level: LevelModel) -> (index: Int, total: Int) {
        if let idx = levels.firstIndex(where: { $0.id == level.id }) {
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
        if let globalIdx = levels.firstIndex(where: { $0.id == current.id }), globalIdx > 0 {
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
        if let globalIdx = levels.firstIndex(where: { $0.id == current.id }), globalIdx + 1 < levels.count {
            return levels[globalIdx + 1]
        }
        if let currentIdx = levels.firstIndex(where: { $0.targetPhrase == current.targetPhrase }), currentIdx + 1 < levels.count {
            return levels[currentIdx + 1]
        }
        return levels.first(where: { !isLevelCompleted($0.id) }) ?? levels.first
    }
    
    public func completeLevel(_ level: LevelModel) {
        userProgress.completedLevelIds.insert(level.id)
        userProgress.totalScore += 10
        
        if let badgeId = level.rewardBadgeId {
            userProgress.unlockedBadgeIds.insert(badgeId)
        }
        
        // 根据解锁关卡自动解锁相应成就勋章
        unlockMilestoneBadges()
        saveProgress()
    }
    
    private func unlockMilestoneBadges() {
        let count = userProgress.completedLevelIds.count
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
            UserDefaults.standard.set(encoded, forKey: userProgressKey)
        }
    }
}

/// 预置数据定义 (包含 200+ 精美名将卡通与四维主题勋章)
public struct PresetData {
    
    public static var defaultLevels: [LevelModel] {
        return (0..<1000).map { Classic10000LevelsEngine.level(at: $0) }
    }
    
    public static var defaultBadges: [BadgeModel] {
        var result: [BadgeModel] = []
        
        // 核心经典人物勋章 (以项羽、刘邦、诸葛亮、李白、杜甫、苏轼、孔子、史记、诗经为首)
        let coreBadges = [
            BadgeModel(id: "badge_xiangyu", name: "西楚霸王", sealText: "项羽\n之印", category: .character, description: "力拔山兮气盖世，破釜沉舟震九州。", requirementDescription: "通关史汉典故关卡【破釜沉舟】解锁", imageName: "badge_xiangyu"),
            BadgeModel(id: "badge_liubang", name: "汉高祖", sealText: "刘邦\n之印", category: .character, description: "大风起兮云飞扬，威加海内兮归故乡。", requirementDescription: "通关史汉典故关卡【四面楚歌】解锁", imageName: "badge_liubang"),
            BadgeModel(id: "badge_zhugeliang", name: "卧龙先生", sealText: "诸葛\n孔明", category: .character, description: "鞠躬尽瘁，死而后已。隆中对策，三国定基。", requirementDescription: "通关史汉典故关卡【三顾茅庐】解锁", imageName: "badge_zhugeliang"),
            BadgeModel(id: "badge_libai", name: "诗仙李白", sealText: "李白\n青莲", category: .character, description: "天生我材必有用，千金散尽还复来。", requirementDescription: "通关唐诗宋词关卡【举头望明月】解锁", imageName: "badge_libai"),
            BadgeModel(id: "badge_dufu", name: "诗圣杜甫", sealText: "杜甫\n子美", category: .character, description: "安得广厦千万间，大庇天下寒士俱欢颜！", requirementDescription: "通关唐诗宋词关卡【会当凌绝顶】解锁", imageName: "badge_dufu"),
            BadgeModel(id: "badge_sushi", name: "东坡居士", sealText: "苏轼\n东坡", category: .character, description: "竹杖芒鞋轻胜马，谁怕？一蓑烟雨任平生。", requirementDescription: "通关唐诗宋词关卡【大江东去】解锁", imageName: "badge_sushi"),
            BadgeModel(id: "badge_shiji", name: "太史公印", sealText: "史记\n典藏", category: .classics, description: "史家之绝唱，无韵之离骚。", requirementDescription: "通关史汉典故关卡【纸上谈兵】解锁", imageName: "badge_shiji"),
            BadgeModel(id: "badge_shijing", name: "诗经雅韵", sealText: "风雅\n颂印", category: .classics, description: "诗三百，一言以蔽之，曰思无邪。", requirementDescription: "通关诗经风雅关卡【关关雎鸠】解锁", imageName: "badge_shijing"),
            BadgeModel(id: "badge_kongzi", name: "万世师表", sealText: "孔丘\n仲尼", category: .character, description: "学而时习之，不亦说乎？有朋自远方来，不亦乐乎？", requirementDescription: "通关诗经风雅关卡【桃之夭夭】解锁", imageName: "badge_kongzi")
        ]
        result.append(contentsOf: coreBadges)
        
        // 1. 生成 55 个【人物名将】卡通勋章 (1..55)
        let charactersList = [
            ("曹操", "魏武", "老骥伏枥，志在千里。烈士暮年，壮心不已。"),
            ("关羽", "关云长", "忠义震华夏，刮骨疗毒威。"),
            ("周瑜", "周公瑾", "羽扇纶巾，谈笑间，樯橹灰飞烟灭。"),
            ("司马迁", "太史公", "究天人之际，通古今之变，成一家之言。"),
            ("屈原", "三闾", "路漫漫其修远兮，吾将上下而求索。"),
            ("王阳明", "致良知", "知行合一，无善无恶心之体。"),
            ("曹雪芹", "石头记", "满纸荒唐言，一把辛酸泪。"),
            ("曾国藩", "涤生", "家勤则兴，人勤则俭，永不贫贱。"),
            ("老子", "道德", "道生一，一生二，二生三，三生万物。"),
            ("庄子", "南华", "乘天地之正，而御六气之辩，以游无穷者。"),
            ("孙武", "兵圣", "知己知彼，百战不殆。"),
            ("韩非子", "法家", "世异则事异，事异则备变。"),
            ("包拯", "包青天", "清正廉明，铁面无私。"),
            ("陶渊明", "五柳", "采菊东篱下，悠然见南山。"),
            ("辛弃疾", "稼轩", "醉里挑灯看剑，梦回吹角连营。"),
            ("欧阳修", "六一", "醉翁之意不在酒，在乎山水之间也。"),
            ("范仲淹", "希文", "先天下之忧而忧，后天下之乐而乐。"),
            ("陆游", "放翁", "王师北定中原日，家祭无忘告乃翁。"),
            ("李清照", "易安", "生当作人杰，死亦为鬼雄。"),
            ("王安石", "半山", "不畏浮云遮望眼，自缘身在最高层。"),
            ("司马光", "漱水", "德胜才谓之君子，才胜德谓之小人。"),
            ("班固", "兰台", "萧规曹随，汉书留名。"),
            ("范晔", "后汉", "疾风知劲草，板荡识诚臣。"),
            ("陈寿", "三国", "三国鼎立，折冲樽俎。"),
            ("刘向", "战国", "战国策勋，古今传承。"),
            ("白居易", "香山", "野火烧不尽，春风吹又生。"),
            ("王维", "摩诘", "行到水穷处，坐看云起时。"),
            ("孟浩然", "襄阳", "春眠不觉晓，处处闻啼鸟。"),
            ("杜牧", "樊川", "停车坐爱枫林晚，霜叶红于二月花。"),
            ("李商隐", "玉溪", "身无彩凤双飞翼，心有灵犀一点通。"),
            ("柳宗元", "河东", "千山鸟飞绝，万径人踪灭。"),
            ("韩愈", "昌黎", "业精于勤，荒于嬉；行成于思，毁于随。"),
            ("贾谊", "洛阳", "少年才俊，宣室求贤。"),
            ("魏征", "贞观", "兼听则明，偏信则暗。"),
            ("房玄龄", "梁国", "房谋杜断，贞观名相。"),
            ("杜如晦", "莱国", "运筹帷幄，断大事捷。"),
            ("郭嘉", "奉孝", "算无遗策，才策谋略。"),
            ("荀彧", "文若", "王佐之才，坚贞守节。"),
            ("陆逊", "伯言", "火烧连营，社稷之臣。"),
            ("姜维", "伯约", "澹泊明志，宁静致远。"),
            ("鲁肃", "子敬", "榻上对策，大智若愚。"),
            ("张良", "子房", "运筹帷幄之中，决胜千里之外。"),
            ("萧何", "文终", "镇国家，抚百姓，给饷馈。"),
            ("韩信", "淮阴", "多多益善，背水一战。"),
            ("霍去病", "冠军", "匈奴未灭，何以家为！"),
            ("卫青", "长平", "龙城飞将，大漠驱匈。"),
            ("岳飞", "武穆", "精忠报国，莫须有撼。"),
            ("文天祥", "信国", "人生自古谁无死？留取丹心照汗青。"),
            ("郑成功", "国姓", "开台宏业，千古英雄。"),
            ("林则徐", "少穆", "苟利国家生死以，岂因祸福避趋之。"),
            ("纪晓岚", "阅微", "四库全书，文章巨公。"),
            ("墨子", "兼爱", "兼相爱，交相利。"),
            ("荀子", "劝学", "青，取之于蓝，而青于蓝。"),
            ("张衡", "平子", "地动天机，精巧绝伦。"),
            ("祖冲之", "文远", "圆周密率，千古神算。")
        ]
        
        for (i, tuple) in charactersList.enumerated() {
            let num = i + 1
            result.append(BadgeModel(
                id: "badge_char_\(num)",
                name: "\(tuple.0)章",
                sealText: "\(tuple.0)\n\(tuple.1)",
                category: .character,
                description: tuple.2,
                requirementDescription: "破解第 \(num) 关或收集专属典故解锁",
                imageName: nil
            ))
        }
        
        // 2. 生成 50 个【功名学阶】勋章 (1..50)
        let academicRanks = [
            "童生启蒙", "秀才中考", "举人高考", "进士考研", "翰林学者", "首辅帝师",
            "状元及第", "榜眼高第", "探花赐宴", "贡士会试", "解元乡试", "秀才案首",
            "诸生第一", "县试双魁", "府试连捷", "院试拔萃", "太学同窗", "国子监官",
            "翰林侍读", "翰林修撰", "文华大学士", "武英大学士", "体仁阁大学士", "东阁大学士",
            "保和殿大学士", "谨身殿大学士", "华盖殿大学士", "中极殿大学士", "建极殿大学士", "文渊阁大学士",
            "尚书大吏", "侍郎高位", "郎中要职", "员外郎尊位", "御史巡按", "刺史地方",
            "太守郡治", "县令亲民", "主簿文书", "秀才童蒙", "举人贡生", "进士及第",
            "状元郎", "榜眼郎", "探花郎", "翰林学士", "侍读学士", "侍讲学士", "国子监生", "帝师首辅"
        ]
        for (i, rankName) in academicRanks.enumerated() {
            let num = i + 1
            result.append(BadgeModel(
                id: "badge_acad_\(num)",
                name: "\(rankName)印",
                sealText: "功名\n\(rankName.prefix(2))",
                category: .academic,
                description: "彰显功名利禄与学阶进阶尊荣，登科及第。",
                requirementDescription: "破解第 \(num * 2) 关或学阶提升解锁",
                imageName: nil
            ))
        }
        
        // 3. 生成 50 个【典籍名篇】勋章 (1..50)
        let classicsList = [
            "史记本纪", "史记世家", "史记列传", "史记书志", "汉书纪传", "后汉列传",
            "三国魏书", "三国蜀书", "三国吴书", "战国策谋", "资治通鉴", "诗经国风",
            "诗经小雅", "诗经大雅", "诗经周颂", "楚辞九歌", "楚辞离骚", "唐诗绝句",
            "唐诗律诗", "宋词豪放", "宋词婉约", "论语学而", "论语为政", "道德无为",
            "孟子离首", "中庸至诚", "大学明德", "礼记儒学", "周易阴阳", "国语楚语",
            "春秋左传", "颜氏家训", "传习致知", "菜根砥砺", "日知匹夫", "小窗慎言",
            "曾家勤俭", "西游客路", "红楼知己", "水浒忠义", "三国鼎立", "孙子知己",
            "孙子九变", "韩非孤愤", "庄子逍遥", "荀子劝学", "墨子兼爱", "尚书虞夏",
            "尚书商周", "经典全辑"
        ]
        for (i, classicName) in classicsList.enumerated() {
            let num = i + 1
            result.append(BadgeModel(
                id: "badge_class_\(num)",
                name: "\(classicName)章",
                sealText: "典籍\n\(classicName.prefix(2))",
                category: .classics,
                description: "千古名篇博大精深，汇聚中华典籍智慧精髓。",
                requirementDescription: "破解第 \(num * 3) 关或研读经典解锁",
                imageName: nil
            ))
        }
        
        // 4. 生成 40 个【处世修养】勋章 (1..40)
        let practicalList = [
            "修身立德", "修身静心", "修身省吾", "修身克己", "齐家和顺", "齐家宜室",
            "齐家教子", "齐家勤俭", "治国经纶", "治国安邦", "治国尚贤", "治国利民",
            "平天下雄心", "平天下抱负", "平天下风云", "平天下功名", "经商奇货", "经商诚信",
            "经商物盛", "经商未雨", "处世交友", "处世恒爱", "处世知己", "处世慎言",
            "处世豁达", "兵法神算", "兵法借箭", "兵法破釜", "兵法攻心", "兵法出奇",
            "德胜君子", "才胜小人", "戒玩物志", "戒欲壑深", "喜时慎言", "怒时慎体",
            "山高客路", "水深渡船", "黄金容易", "知心难求"
        ]
        for (i, pracName) in practicalList.enumerated() {
            let num = i + 1
            result.append(BadgeModel(
                id: "badge_prac_\(num)",
                name: "\(pracName)印",
                sealText: "修养\n\(pracName.prefix(2))",
                category: .practical,
                description: "学以致用，知行合一。内圣外王，圆融处世。",
                requirementDescription: "破解第 \(num * 4) 关或悟道修养解锁",
                imageName: nil
            ))
        }
        
        return result
    }
}
