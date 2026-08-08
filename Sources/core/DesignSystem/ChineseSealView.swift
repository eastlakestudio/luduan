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
    
    private func loadCartoonImage(named name: String) -> Image? {
        var targetName = name
        if name.hasPrefix("badge_acad_1") {
            targetName = "badge_academic_tongsheng"
        } else if name.hasPrefix("badge_acad_2") {
            targetName = "badge_academic_xiucai"
        } else if name.hasPrefix("badge_acad_3") {
            targetName = "badge_academic_juren"
        } else if name.hasPrefix("badge_acad_4") {
            targetName = "badge_academic_jinshi"
        } else if name.hasPrefix("badge_acad_5") {
            targetName = "badge_academic_hanlin"
        } else if name.hasPrefix("badge_acad_6") || name.hasPrefix("badge_acad_7") || name.hasPrefix("badge_acad_8") || name.hasPrefix("badge_acad_9") || name.hasPrefix("badge_acad_10") || name.hasPrefix("badge_acad_11") || name.hasPrefix("badge_acad_12") || name.hasPrefix("badge_acad_13") {
            targetName = "badge_academic_shoufu"
        } else if name == "badge_char_1" {
            targetName = "badge_caocao"
        } else if name == "badge_char_2" {
            targetName = "badge_guanyu"
        } else if name == "badge_char_3" {
            targetName = "badge_lubu"
        } else if name == "badge_char_5" {
            targetName = "badge_zhangfei"
        } else if name == "badge_char_47" || name == "badge_yuefei" {
            targetName = "badge_yuefei"
        }
        
        #if canImport(UIKit)
        if let uiImage = UIImage(named: targetName, in: .module, compatibleWith: nil) ?? UIImage(named: targetName) {
            return Image(uiImage: uiImage)
        }
        if let url = Bundle.module.url(forResource: targetName, withExtension: "jpg") ??
                     Bundle.module.url(forResource: targetName, withExtension: "jpg", subdirectory: "BadgeImages"),
           let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        if let url = Bundle.module.url(forResource: targetName, withExtension: "png") ??
                     Bundle.module.url(forResource: targetName, withExtension: "png", subdirectory: "BadgeImages"),
           let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        #elseif canImport(AppKit)
        if let url = Bundle.module.url(forResource: targetName, withExtension: "jpg") ??
                     Bundle.module.url(forResource: targetName, withExtension: "jpg", subdirectory: "BadgeImages"),
           let data = try? Data(contentsOf: url),
           let nsImage = NSImage(data: data) {
            return Image(nsImage: nsImage)
        }
        if let url = Bundle.module.url(forResource: targetName, withExtension: "png") ??
                     Bundle.module.url(forResource: targetName, withExtension: "png", subdirectory: "BadgeImages"),
           let data = try? Data(contentsOf: url),
           let nsImage = NSImage(data: data) {
            return Image(nsImage: nsImage)
        }
        #endif
        return nil
    }
    
    private func isLegacyLineDrawing(_ imageName: String?) -> Bool {
        guard let name = imageName else { return false }
        return name.hasPrefix("badge_char_") && !["badge_char_1", "badge_char_2", "badge_char_3", "badge_char_5", "badge_char_47"].contains(name)
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
