import Foundation

/// 典籍种子项解析模型
public struct ClassicalSeedItem: Codable {
    public let phrase: String
    public let annotation: String
    public let story: String
    public let source: String
    
    public init(phrase: String, annotation: String, story: String, source: String) {
        self.phrase = phrase
        self.annotation = annotation
        self.story = story
        self.source = source
    }
}

/// 一万关（10,000 关）程序化生成引擎（基于独立 JSON 种子库动态加载）
public final class Classic10000LevelsEngine {
    
    public static let totalLevelsCount = 10000
    
    // 动态缓存各典籍 JSON 种子库
    private static var seedsCache: [String: [ClassicalSeedItem]] = [:]
    
    /// 从 Bundle.module 资源包加载指定的 JSON 种子库
    public static func loadSeeds(named name: String) -> [ClassicalSeedItem] {
        if let cached = seedsCache[name] {
            return cached
        }
        guard let url = Bundle.module.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let items = try? JSONDecoder().decode([ClassicalSeedItem].self, from: data) else {
            return []
        }
        seedsCache[name] = items
        return items
    }
    
    private static let cachedAllSeeds: [ClassicalSeedItem] = {
        let fileNames = [
            "shiji", "shangshu", "zhouyi", "liji", "daxue", "hanshu", "houhanshu",
            "sanguozhi", "zizhitongjian", "zhanguoce", "zhuangzi", "xunzi", "hanfeizi",
            "sunzibingfa", "huainanzi", "lvshichunqiu", "chuci", "zhaomingwenxuan", "wenxindiaolong",
            "tangshi", "songci", "huajianyuefu", "zhuzijiaxun", "sanguoyanyi", "shuihuzhuan",
            "liaozhaizhiyi", "shihan", "shijing", "tangsong", "lunyu", "daodejing",
            "mengzi", "zhongyong", "guoyu", "chunqiu", "yanshijiaxun",
            "chuanxilu", "caigentan", "rizhilu", "xiaochuangyouji",
            "zengguofanjiashu", "xiyouji", "hongloumeng"
        ]
        var combined: [ClassicalSeedItem] = []
        for fn in fileNames {
            combined.append(contentsOf: loadSeeds(named: fn))
        }
        return combined
    }()
    
    /// 获取所有 17 个已加载的 JSON 种子库集合（已优化为静态只读缓存）
    public static var allCombinedSeeds: [ClassicalSeedItem] {
        return cachedAllSeeds
    }
    
    /// 核心方法：基于确定性算法获取第 `1` 到第 `10,000` 关中的任意关卡 (0-indexed)
    public static func level(at index: Int, categoryName: String = "") -> LevelModel {
        let safeIndex = max(0, min(index, totalLevelsCount - 1))
        let levelNumber = safeIndex + 1
        
        let allSeeds = allCombinedSeeds
        let seedCount = max(1, allSeeds.count)
        
        // 5 大朝代年代种子库归类
        let theme: CultureTheme
        let rawSeed: ClassicalSeedItem
        
        if safeIndex < 2500 {
            // 先秦典籍源头 (0..<2500)：仅包含《诗经》《论语》《道德经》《孟子》《中庸》《国语》《春秋》
            theme = .shijing
            let items = loadSeeds(named: "shijing") + loadSeeds(named: "lunyu") + loadSeeds(named: "daodejing") + loadSeeds(named: "mengzi") + loadSeeds(named: "zhongyong") + loadSeeds(named: "guoyu") + loadSeeds(named: "chunqiu")
            rawSeed = items.isEmpty ? allSeeds[safeIndex % seedCount] : items[safeIndex % items.count]
        } else if safeIndex < 5500 {
            // 两汉三国史册 (2500..<5500)：包含《史记》《汉书》《战国策》《三国志》成语典故
            theme = .shihan
            let items = loadSeeds(named: "shihan")
            rawSeed = items.isEmpty ? allSeeds[safeIndex % seedCount] : items[(safeIndex - 2500) % items.count]
        } else if safeIndex < 7000 {
            // 魏晋南北朝 (5500..<7000)：包含《颜氏家训》与魏晋风骨
            theme = .shihan
            let items = loadSeeds(named: "yanshijiaxun") + loadSeeds(named: "shihan")
            rawSeed = items.isEmpty ? allSeeds[safeIndex % seedCount] : items[(safeIndex - 5500) % items.count]
        } else if safeIndex < 8800 {
            // 唐宋诗词史鉴 (7000..<8800)：专门包含《唐诗三百首》与《宋词名篇》
            theme = .tangsong
            let items = loadSeeds(named: "tangsong")
            rawSeed = items.isEmpty ? allSeeds[safeIndex % seedCount] : items[(safeIndex - 7000) % items.count]
        } else {
            // 明清名著与家书 (8800..<10000)：包含《传习录》《菜根谭》《曾国藩家书》《四大名著》
            theme = .shijing
            let items = loadSeeds(named: "chuanxilu") + loadSeeds(named: "caigentan") + loadSeeds(named: "rizhilu") + loadSeeds(named: "xiaochuangyouji") + loadSeeds(named: "zengguofanjiashu") + loadSeeds(named: "xiyouji") + loadSeeds(named: "hongloumeng")
            rawSeed = items.isEmpty ? allSeeds[safeIndex % seedCount] : items[(safeIndex - 8800) % items.count]
        }
        
        let levelId = "level_\(levelNumber)"
        let displayTitle = "第 \(levelNumber) 关"
        
        // 动态自适应生成 16 字乱序矩阵
        let tileMatrix = generateDeterministic16Tiles(for: rawSeed.phrase, seedIndex: safeIndex)
        
        return LevelModel(
            id: levelId,
            theme: theme,
            title: displayTitle,
            categoryName: categoryName,
            targetPhrase: rawSeed.phrase,
            tileMatrix: tileMatrix,
            annotation: rawSeed.annotation,
            story: rawSeed.story,
            source: rawSeed.source
        )
    }
    
    /// 确定性乱序 16 字矩阵算法（支持长句与多字数诗词）
    private static func generateDeterministic16Tiles(for phrase: String, seedIndex: Int) -> [String] {
        let distractors = [
            "天", "地", "玄", "黄", "宇", "宙", "洪", "荒", "日", "月",
            "盈", "昃", "辰", "宿", "列", "张", "寒", "来", "暑", "往",
            "秋", "收", "冬", "藏", "闰", "余", "成", "岁", "律", "吕",
            "调", "阳", "云", "腾", "致", "雨", "露", "结", "为", "霜",
            "金", "生", "丽", "水", "玉", "出", "昆", "冈", "剑", "号",
            "巨", "阙", "珠", "称", "夜", "光", "果", "珍", "李", "柰"
        ]
        
        var targetChars = Array(phrase).map { String($0) }
        var result = targetChars
        
        let targetGridCount = max(16, targetChars.count + 4)
        var dIndex = seedIndex % distractors.count
        
        while result.count < targetGridCount {
            let candidate = distractors[dIndex % distractors.count]
            if !result.contains(candidate) {
                result.append(candidate)
            }
            dIndex += 7
        }
        
        var pseudoSeed = seedIndex * 997 + 13
        for i in (1..<result.count).reversed() {
            pseudoSeed = (pseudoSeed * 1103515245 + 12345) & 0x7fffffff
            let j = pseudoSeed % (i + 1)
            result.swapAt(i, j)
        }
        
        return result
    }
}
