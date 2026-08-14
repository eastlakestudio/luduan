import SwiftUI

public struct ChineseSealView: View {
    public let text: String
    public let isUnlocked: Bool
    public let size: CGFloat
    public let imageName: String?
    
    public init(text: String, isUnlocked: Bool = true, size: CGFloat = 72, imageName: String? = nil) {
        self.text = text
        self.isUnlocked = isUnlocked
        self.size = size
        self.imageName = imageName
    }
    
    public var body: some View {
        ZStack {
            if let imageName = imageName, let image = loadCartoonImage(named: imageName) {
                // 卡通名士肖像印章模式 (全貌无切断适配 + 动态京剧彩绘色彩强化)
                let isLegacy = isLegacyLineDrawing(imageName)
                let themePalette = characterThemePalette(for: imageName)
                
                ZStack {
                    if isLegacy {
                        // 1. 底层：鲜艳京剧云纹锦绣色彩背景
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: themePalette.backgroundColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: size, height: size)
                        
                        // 2. 中层：黑白线稿彩色化 Multiply 叠加
                        image
                            .resizable()
                            .scaledToFill()
                            .colorMultiply(themePalette.lineTint)
                            .contrast(1.3)
                            .brightness(0.05)
                            .frame(width: size * 0.9, height: size * 0.9)
                            .clipShape(Circle())
                    } else {
                        // 高清彩绘/京剧高清立绘模式
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                    }
                }
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .strokeBorder(
                            isUnlocked ? Color.cloudGold : Color.gray.opacity(0.4),
                            lineWidth: max(2, size * 0.04)
                        )
                )
                .grayscale(isUnlocked ? 0.0 : 1.0)
                .opacity(isUnlocked ? 1.0 : 0.45)
                
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: size * 0.28))
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                }
            } else {
                // 传统古风水墨朱印模式
                ZStack {
                    RoundedRectangle(cornerRadius: size * 0.15)
                        .strokeBorder(isUnlocked ? Color.cinnabarRed : Color.gray.opacity(0.4), lineWidth: 3)
                        .background(
                            RoundedRectangle(cornerRadius: size * 0.15)
                                .fill(isUnlocked ? Color.cinnabarRed.opacity(0.08) : Color.gray.opacity(0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: size * 0.12)
                                .strokeBorder(isUnlocked ? Color.cinnabarRed : Color.gray.opacity(0.3), lineWidth: 1)
                                .padding(4)
                        )
                    
                    Text(text)
                        .font(.system(size: size * 0.35, weight: .bold, design: .serif))
                        .foregroundColor(isUnlocked ? Color.cinnabarRed : Color.gray.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.6)
                        .padding(6)
                }
                .opacity(isUnlocked ? 1.0 : 0.6)
            }
        }
        .frame(width: size, height: size)
    }
    
        private static var imageCache: [String: Image] = [:]

    public static func hasCartoonImage(named imageName: String?, text: String = "") -> Bool {
        guard let name = resolveImageName(for: imageName, text: text) else { return false }
        return canLoadImage(named: name)
    }

    public static func resolveImageName(for rawName: String?, text: String = "") -> String? {
        guard let raw = rawName, !raw.isEmpty, raw != "none" else {
            return resolveByText(text)
        }
        
        let clean = raw.replacingOccurrences(of: ".png", with: "").replacingOccurrences(of: ".jpg", with: "")
        
        // 1. 科举功名分类
        if clean.hasPrefix("badge_level_1") || clean.hasPrefix("badge_acad_1") || text.contains("童生") {
            return "badge_academic_tongsheng"
        } else if clean.hasPrefix("badge_level_2") || clean.hasPrefix("badge_acad_2") || text.contains("秀才") {
            return "badge_academic_xiucai"
        } else if clean.hasPrefix("badge_level_3") || clean.hasPrefix("badge_acad_3") || text.contains("举人") {
            return "badge_academic_juren"
        } else if clean.hasPrefix("badge_level_4") || clean.hasPrefix("badge_level_5") || clean.hasPrefix("badge_acad_4") || clean.hasPrefix("badge_acad_5") || text.contains("贡士") || text.contains("进士") {
            return "badge_academic_jinshi"
        } else if clean.hasPrefix("badge_level_6") || clean.hasPrefix("badge_acad_6") || text.contains("翰林") {
            return "badge_academic_hanlin"
        } else if clean.hasPrefix("badge_level_7") || clean.hasPrefix("badge_level_8") || clean.hasPrefix("badge_level_9") || clean.hasPrefix("badge_acad_") || text.contains("内阁") || text.contains("首辅") || text.contains("帝师") {
            return "badge_academic_shoufu"
        }
        
        // 2. 处世修养分类 (badge_prac_1 ~ 40)
        if clean.hasPrefix("badge_prac_") {
            return clean
        } else if clean.hasPrefix("badge_theme_") || clean == "badge_default_theme" {
            let index = (abs(clean.hashValue ^ text.hashValue) % 40) + 1
            return "badge_prac_\(index)"
        }
        
        // 3. 典籍名篇 / 人物名将直接命中
        if canLoadImage(named: clean) {
            return clean
        }
        
        // 4. 根据短语或典籍名称语义推导
        if let byText = resolveByText(text) {
            return byText
        }
        
        if clean == "badge_default_book" {
            return "badge_shiji"
        }
        
        return nil
    }
    
    private static func resolveByText(_ text: String) -> String? {
        guard !text.isEmpty else { return nil }
        
        // 名著与先秦诸子典籍
        if text.contains("诗经") { return "badge_shijing" }
        if text.contains("史记") { return "badge_shiji" }
        if text.contains("论语") || text.contains("大学") || text.contains("中庸") || text.contains("孟子") || text.contains("孔子") { return "badge_kongzi" }
        if text.contains("道德经") || text.contains("老子") { return "badge_laozi" }
        if text.contains("庄子") { return "badge_zhuangzi" }
        if text.contains("荀子") { return "badge_xunzi" }
        if text.contains("墨子") { return "badge_mozi" }
        if text.contains("韩非子") || text.contains("韩非") { return "badge_hanfeizi" }
        if text.contains("孙子") || text.contains("兵法") || text.contains("孙武") { return "badge_sunwu" }
        if text.contains("楚辞") || text.contains("屈原") || text.contains("离骚") { return "badge_quyuan" }
        if text.contains("汉书") || text.contains("班固") { return "badge_bangu" }
        if text.contains("后汉书") || text.contains("范晔") { return "badge_fanye" }
        if text.contains("三国志") || text.contains("陈寿") { return "badge_chenshou" }
        if text.contains("资治通鉴") || text.contains("司马光") { return "badge_simaguang" }
        if text.contains("红楼梦") || text.contains("曹雪芹") { return "badge_caoxueqin" }
        if text.contains("传习录") || text.contains("王阳明") || text.contains("阳明") { return "badge_wangyangming" }
        if text.contains("过秦论") || text.contains("贾谊") { return "badge_jiayi" }
        if text.contains("战国策") || text.contains("说苑") || text.contains("刘向") { return "badge_liuxiang" }
        
        // 历代文坛宗师与诗词巨匠
        if text.contains("李白") || text.contains("太白") { return "badge_libai" }
        if text.contains("杜甫") || text.contains("子美") { return "badge_dufu" }
        if text.contains("苏轼") || text.contains("东坡") { return "badge_sushi" }
        if text.contains("王维") || text.contains("摩诘") { return "badge_wangwei" }
        if text.contains("白居易") || text.contains("乐天") { return "badge_baijuyi" }
        if text.contains("辛弃疾") || text.contains("稼轩") { return "badge_xinqiji" }
        if text.contains("李清照") || text.contains("易安") { return "badge_liqingzhao" }
        if text.contains("欧阳修") || text.contains("醉翁") { return "badge_ouyangxiu" }
        if text.contains("陆游") || text.contains("放翁") { return "badge_luyou" }
        if text.contains("范仲淹") { return "badge_fanzhongyan" }
        if text.contains("陶渊明") || text.contains("五柳") { return "badge_taoyuanming" }
        if text.contains("孟浩然") { return "badge_menghaoran" }
        if text.contains("杜牧") { return "badge_dumu" }
        if text.contains("李商隐") { return "badge_lishangyin" }
        if text.contains("韩愈") || text.contains("昌黎") { return "badge_hanyu" }
        if text.contains("柳宗元") { return "badge_liuzongyuan" }
        if text.contains("王安石") { return "badge_wanganshi" }
        if text.contains("鲁迅") { return "badge_luxun" }
        if text.contains("纪晓岚") || text.contains("阅微草堂") { return "badge_jixiaolan" }
        
        // 历代名将、先贤与帝王名臣
        if text.contains("岳飞") { return "badge_yuefei" }
        if text.contains("文天祥") { return "badge_wentianxiang" }
        if text.contains("诸葛亮") || text.contains("孔明") { return "badge_zhugeliang" }
        if text.contains("曹操") { return "badge_caocao" }
        if text.contains("关羽") { return "badge_guanyu" }
        if text.contains("张飞") { return "badge_zhangfei" }
        if text.contains("周瑜") { return "badge_zhouyu" }
        if text.contains("鲁肃") { return "badge_lusu" }
        if text.contains("吕布") { return "badge_lubu" }
        if text.contains("霍去病") { return "badge_huoqubing" }
        if text.contains("卫青") { return "badge_weiqing" }
        if text.contains("韩信") { return "badge_hanxin" }
        if text.contains("张良") { return "badge_zhangliang" }
        if text.contains("萧何") { return "badge_xiaohe" }
        if text.contains("刘邦") { return "badge_liubang" }
        if text.contains("项羽") { return "badge_xiangyu" }
        if text.contains("林则徐") { return "badge_linzexu" }
        if text.contains("曾国藩") { return "badge_zengguofan" }
        if text.contains("包拯") || text.contains("包公") { return "badge_baozheng" }
        if text.contains("司马迁") { return "badge_simaqian" }
        if text.contains("魏征") { return "badge_weizheng" }
        if text.contains("房玄龄") { return "badge_fangxuanling" }
        if text.contains("杜如晦") { return "badge_duruhui" }
        if text.contains("郭嘉") { return "badge_guojia" }
        if text.contains("荀彧") { return "badge_xunyu" }
        if text.contains("姜维") { return "badge_jiangwei" }
        if text.contains("郑成功") { return "badge_zhengchenggong" }
        if text.contains("张衡") { return "badge_zhangheng" }
        if text.contains("祖冲之") { return "badge_zuchongzhi" }
        
        return nil
    }

    private static func canLoadImage(named name: String) -> Bool {
        #if canImport(UIKit)
        if UIImage(named: name, in: .module, compatibleWith: nil) != nil || UIImage(named: name) != nil {
            return true
        }
        let bundles = [Bundle.main, Bundle.module, Bundle(for: GameDataRepository.self)]
        for bundle in bundles {
            if bundle.url(forResource: name, withExtension: "jpg") != nil ||
               bundle.url(forResource: name, withExtension: "jpg", subdirectory: "BadgeImages") != nil ||
               bundle.url(forResource: name, withExtension: "png") != nil ||
               bundle.url(forResource: name, withExtension: "png", subdirectory: "BadgeImages") != nil {
                return true
            }
        }
        #endif
        return false
    }

    private func loadCartoonImage(named imageName: String) -> Image? {
        guard let targetName = Self.resolveImageName(for: imageName, text: text) else {
            return nil
        }
        
        if let cached = Self.imageCache[targetName] {
            return cached
        }
        
        var loadedImage: Image? = nil
        
        #if canImport(UIKit)
        if let uiImage = UIImage(named: targetName, in: .module, compatibleWith: nil) ?? UIImage(named: targetName) {
            loadedImage = Image(uiImage: uiImage)
        } else {
            let bundles = [Bundle.main, Bundle.module, Bundle(for: GameDataRepository.self)]
            for bundle in bundles {
                if let url = bundle.url(forResource: targetName, withExtension: "jpg") ??
                             bundle.url(forResource: targetName, withExtension: "jpg", subdirectory: "BadgeImages") ??
                             bundle.url(forResource: targetName, withExtension: "png") ??
                             bundle.url(forResource: targetName, withExtension: "png", subdirectory: "BadgeImages"),
                   let data = try? Data(contentsOf: url),
                   let uiImage = UIImage(data: data) {
                    loadedImage = Image(uiImage: uiImage)
                    break
                }
            }
        }
        #elseif canImport(AppKit)
        let bundles = [Bundle.main, Bundle.module]
        for bundle in bundles {
            if let url = bundle.url(forResource: targetName, withExtension: "jpg") ??
                         bundle.url(forResource: targetName, withExtension: "jpg", subdirectory: "BadgeImages") ??
                         bundle.url(forResource: targetName, withExtension: "png") ??
                         bundle.url(forResource: targetName, withExtension: "png", subdirectory: "BadgeImages"),
               let data = try? Data(contentsOf: url),
               let nsImage = NSImage(data: data) {
                loadedImage = Image(nsImage: nsImage)
                break
            }
        }
        #endif
        
        if let img = loadedImage {
            Self.imageCache[targetName] = img
        }
        return loadedImage
    }
    
    private func isLegacyLineDrawing(_ imageName: String?) -> Bool {
        return false
    }

    private struct CharacterPalette {
        let backgroundColors: [Color]
        let lineTint: Color
    }

    private func characterThemePalette(for imageName: String?) -> CharacterPalette {
        guard let name = imageName else {
            return CharacterPalette(backgroundColors: [Color.cinnabarRed, Color.cloudGold], lineTint: .white)
        }
        let hash = abs(name.hashValue) % 4
        switch hash {
        case 0:
            // 戏曲朱红与云锦金（名将/武臣）
            return CharacterPalette(
                backgroundColors: [Color.cinnabarRed.opacity(0.88), Color.cloudGold.opacity(0.9)],
                lineTint: Color(red: 1.0, green: 0.92, blue: 0.75)
            )
        case 1:
            // 孔雀绿与翡翠青（名士/学者）
            return CharacterPalette(
                backgroundColors: [Color.bambooGreen.opacity(0.9), Color(red: 0.1, green: 0.6, blue: 0.5)],
                lineTint: Color(red: 0.9, green: 1.0, blue: 0.9)
            )
        case 2:
            // 皇家紫与璀璨金（文坛宗师/名相）
            return CharacterPalette(
                backgroundColors: [Color(red: 0.48, green: 0.18, blue: 0.65), Color.cloudGold.opacity(0.85)],
                lineTint: Color(red: 1.0, green: 0.95, blue: 0.8)
            )
        default:
            // 湛蓝与景泰蓝（诗人/哲人）
            return CharacterPalette(
                backgroundColors: [Color(red: 0.12, green: 0.38, blue: 0.78), Color(red: 0.2, green: 0.72, blue: 0.92)],
                lineTint: Color(red: 0.92, green: 0.96, blue: 1.0)
            )
        }
    }
}
