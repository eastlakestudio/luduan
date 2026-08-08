import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public extension Color {
    private static func adaptive(light: (CGFloat, CGFloat, CGFloat),
                                 dark: (CGFloat, CGFloat, CGFloat)) -> Color {
        #if canImport(UIKit)
        return Color(UIColor { trait in
            let (r, g, b) = trait.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: r, green: g, blue: b, alpha: 1)
        })
        #else
        return Color(red: light.0, green: light.1, blue: light.2)
        #endif
    }

    /// 朱砂红 - 典雅中式主调红（暗色下略提亮）
    static let cinnabarRed = adaptive(light: (0.78, 0.24, 0.14), dark: (0.90, 0.36, 0.24))

    /// 竹青绿 - 清雅古典绿
    static let bambooGreen = adaptive(light: (0.47, 0.57, 0.38), dark: (0.62, 0.72, 0.52))

    /// 宣纸白 / 墨卷底 - 主背景（暗色为深墨褐）
    static let paperWhite = adaptive(light: (0.97, 0.96, 0.92), dark: (0.10, 0.09, 0.08))

    /// 玄青黑 / 象牙白 - 主文字（暗色为暖象牙）
    static let xuanBlack = adaptive(light: (0.11, 0.11, 0.13), dark: (0.92, 0.89, 0.82))

    /// 卡片/槽位表面（暗色为略亮于底色的墨卡）
    static let cardSurface = adaptive(light: (1.0, 1.0, 1.0), dark: (0.17, 0.16, 0.14))

    /// 祥云金 - 辉光金黄色（暗色下更亮）
    static let cloudGold = adaptive(light: (0.83, 0.64, 0.35), dark: (0.92, 0.74, 0.44))

    /// 黛蓝 - 沉稳次要色
    static let daiBlue = adaptive(light: (0.22, 0.32, 0.42), dark: (0.45, 0.58, 0.70))

    /// 仿古边框灰（暗色为暗金灰）
    static let borderAncient = adaptive(light: (0.82, 0.78, 0.70), dark: (0.38, 0.34, 0.28))
}
