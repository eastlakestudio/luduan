import Foundation

/// 典籍种子项解析模型
public struct ClassicalSeedItem: Codable {
    public let phrase: String
    public let annotation: String
    public let story: String
    public let source: String
    public let idx: Int?
    
    public init(phrase: String, annotation: String, story: String, source: String, idx: Int? = nil) {
        self.phrase = phrase
        self.annotation = annotation
        self.story = story
        self.source = source
        self.idx = idx
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
    
    public static func levelFromWord(
        _ word: ClassicalSeedItem,
        categoryName: String = "",
        badgeId: String? = nil,
        rewardBadgeId: String? = nil
    ) -> LevelModel {
        let theme: CultureTheme
        if word.source.contains("诗经") {
            theme = .shijing
        } else if word.source.contains("唐") || word.source.contains("宋") || word.source.contains("词") || word.source.contains("李白") || word.source.contains("杜甫") || word.source.contains("王维") || word.source.contains("花间") || word.source.contains("诗") {
            theme = .tangsong
        } else {
            theme = .shihan
        }
        
        let levelId = "level_\(abs(word.phrase.hashValue))"
        let displayTitle = word.phrase
        
        // 动态自适应生成 16 字乱序矩阵
        // 为确保矩阵生成确定性，使用 phrase 自身的 hash 作为伪随机种子
        let tileMatrix = generateDeterministic16Tiles(for: word.phrase, seedIndex: abs(word.phrase.hashValue))
        
        return LevelModel(
            id: levelId,
            theme: theme,
            title: displayTitle,
            categoryName: categoryName,
            targetPhrase: word.phrase,
            tileMatrix: tileMatrix,
            annotation: word.annotation,
            story: word.story,
            source: word.source,
            badgeId: badgeId,
            rewardBadgeId: rewardBadgeId
        )
    }
    
    // 精简 800 个核心高频字库池（从成语名句中提取的最高频核心汉字，彻底过滤掉换行符与空格）
    public static let allUniqueChars: [String] = {
        let raw = """
不之一人无风山天日相为心水有如云自花月千下行里来言春以马何上生中而长三时金去夜雨知落白年秋明子大高门地万君成尽见飞道得东酒出江清重可家事百玉我望色欲远城若草当深
今思流此气在归声处南龙黄书入国海意安情十西同衣世死目青叶雪老难食未路好名身闻断公北绝鱼前空头客兵别树文寒手古多小后从发足楼石故将柳朝离能口其是正五莫分问外两起暮
河失已过阳开鸟红尘与平众火坐面物林余游苦新满举回作梦歌穷谁才所功惊竹烟绿看少遗愁车醉易吹于先木画折鸣者九光孤非力更兮四剑然本枝虎旧合边独散燕桃取曲乐解胡士神连野
交向湖露经间志轻尺斗紫凤度至民垂骨方辞牛舟沉扬乡楚冠夫兴沙齿鼎动义反浮应复悲终雁及笑节战容首胜立关泪逢香俗初珠泉居武待土祸毛识听二步指随台伤横女恨鸡极命变久利投
比饮求乘细李直登晓积似汉临王观须常悬顾改走户军恶薄塞语送席带还锦霜怀影半吴波异转计疾狼乱儿华和岁美戈晚持微田角博甲主忘令扫耳善枕舞宫爱危败息鼓腹覆图末势芳逐犹臣
形学肉群狗掩短对残累佳因使破必用狐秦碧杨忽夕负刀背视杯壮池冰真干倚唯昔萧虽良会川贵谈根犬州虚师俱私论眉双劳报法阴亦兰都眼梅悠到溪景罗卷寻堂张德雄倾骑寡卧亡移庭杜
始松园己闲照富恩章留含寸共精敌倒忧信济任盘怨诗八几怒室且采舍枯拔贤实闭官皆市渐结代颜数阁灯教传徒幽冷凉岸忆量奇守就全昼接弃引丝摧聚鸿挂封杀决止铁谢宵六振荒父片却
越借愿欢条袖素念急盗静鹤驱争布往鼠端寄迹休靡击啼苍梁桂左吾征径飘只把寂薪星依再著郎威亲载策宾纵进化迷遥钟强纳追太泣丹奉疏贫狂藏荷最机仙童帝冲晨谷骥叹痛纷泥淡并宁
致惜筹魂英管厚电堪屋则谋运要尔甘达放业牙屈羁贱卖浅履疑摇弄镜村早圣血近洞竟曾晴伏翠岂期桑广阿肩齐弦胆七退贯坚修焚抱迁壑厉夷渔裘笔射井想亭床病映阶既又阙毁陵宿拂怜
浦隔销烛肠灭类忍礼附旗固补感操肝规避遭雀元各勇汤诸荆浪说弟差宜通迟穿汗执便种尚兔旋除泽集岩尊钱雾吟窗暗漠但甚瑟丰羽翼逾涂虑表唇翻绣蛇读竭豪鹿藉瓜茅罪旷黑了废析贪
"""
        return raw.filter { !$0.isWhitespace && !$0.isNewline && !$0.isPunctuation }.map { String($0) }
    }()
    
    /// 确定性乱序 12 字 (3x4) 矩阵算法（支持长句与多字数诗词，干扰字动态来源于全量词库）
    private static func generateDeterministic16Tiles(for phrase: String, seedIndex: Int) -> [String] {
        let distractors = allUniqueChars
        let targetChars = Array(phrase).filter { !$0.isWhitespace && !$0.isNewline && !$0.isPunctuation }.map { String($0) }
        var result = targetChars
        
        let targetGridCount = max(12, targetChars.count)
        var dIndex = abs(seedIndex) % max(1, distractors.count)
        
        while result.count < targetGridCount {
            let candidate = distractors[dIndex % distractors.count]
            let trimmed = candidate.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty && !result.contains(trimmed) {
                result.append(trimmed)
            }
            dIndex = (dIndex + 37) % distractors.count
        }
        
        var pseudoSeed = UInt64(bitPattern: Int64(seedIndex)) &* 997 &+ 13
        for i in (1..<result.count).reversed() {
            pseudoSeed = (pseudoSeed &* 1103515245 &+ 12345) & 0x7fffffff
            let j = Int(pseudoSeed % UInt64(i + 1))
            result.swapAt(i, j)
        }
        
        return result
    }
}
