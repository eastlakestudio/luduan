import Foundation

/// 标准汉语拼音映射助手
public struct PinyinHelper {
    private static let pinyinDict: [String: String] = [
        // 楚汉/典故字
        "破": "pò", "釜": "fǔ", "沉": "chén", "舟": "zhōu",
        "四": "sì", "面": "miàn", "楚": "chǔ", "歌": "gē",
        "项": "xiàng", "羽": "yǔ", "刘": "liú", "邦": "bāng",
        "鸿": "hóng", "门": "mén", "宴": "yàn", "背": "bèi",
        "水": "shuǐ", "一": "yī", "战": "zhàn", "霸": "bà",
        "王": "wáng", "别": "bié", "姬": "jī", "指": "zhǐ",
        "鹿": "lù", "为": "wéi", "马": "mǎ", "汉": "hàn",
        "秦": "qín", "兵": "bīng", "天": "tiān", "下": "xià",
        "成": "chéng", "败": "bài", "古": "gǔ", "今": "jīn",
        
        // 诗经名句字
        "关": "guān", "雎": "jū", "鸠": "jiū", "在": "zài",
        "河": "hé", "之": "zhī", "洲": "zhōu", "窈": "yǎo",
        "窕": "tiǎo", "淑": "shū", "女": "nǚ", "君": "jūn",
        "子": "zǐ", "好": "hǎo", "逑": "qiú", "兼": "jiān",
        "葭": "jiā", "苍": "cāng", "白": "bái", "露": "lù",
        "霜": "shuāng", "桃": "táo", "夭": "yāo",
        "灼": "zhuó", "华": "huá", "宜": "yí", "室": "shì",
        "家": "jiā",
        
        // 唐诗宋词字
        "床": "chuáng", "前": "qián", "明": "míng", "月": "yuè",
        "光": "guāng", "疑": "yí", "是": "shì", "地": "dì",
        "上": "shàng", "举": "jǔ", "头": "tóu",
        "望": "wàng", "低": "dī", "思": "sī", "故": "gù",
        "乡": "xiāng", "国": "guó", "山": "shān", "城": "chéng",
        "春": "chūn", "草": "cǎo", "木": "mù", "深": "shēn",
        "感": "gǎn", "时": "shí", "花": "huā", "溅": "jiàn",
        "泪": "lèi", "恨": "hèn", "鸟": "niǎo", "惊": "jīng",
        "心": "xīn", "调": "tiáo", "丙": "bǐng", "辰": "chén",
        "中": "zhōng", "秋": "qiū", "欢": "huān", "饮": "yǐn",
        "达": "dá", "旦": "dàn", "大": "dà", "醉": "zuì",
        "风": "fēng", "云": "yún", "志": "zhì", "文": "wén",
        "武": "wǔ", "诗": "shī", "书": "shū", "画": "huà", "史": "shǐ",
        "尽": "jìn", "野": "yě", "吹": "chuī", "烧": "shāo"
    ]
    
    /// 获取指定单字的带声调拼音
    public static func pinyin(for char: String) -> String {
        if let py = pinyinDict[char] {
            return py
        }
        // 若缺失映射，动态提取拼音音素
        let mutableString = NSMutableString(string: char) as CFMutableString
        CFStringTransform(mutableString, nil, kCFStringTransformMandarinLatin, false)
        let result = (mutableString as String).trimmingCharacters(in: .whitespacesAndNewlines)
        return result.isEmpty ? char : result
    }
    
    /// 获取指定单字的无声调拼音（用于同音字/多音字语音高精度匹配）
    public static func pinyinWithoutTone(for char: String) -> String {
        let raw = pinyin(for: char)
        return raw.folding(options: .diacriticInsensitive, locale: Locale(identifier: "en_US")).lowercased()
    }
}
