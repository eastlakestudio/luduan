import SwiftUI

/// iPad 与大屏自适应布局辅助库
public struct AdaptiveLayoutHelper {
    /// 根据当前 UI 尺寸类计算网格合适列数
    /// - Parameters:
    ///   - sizeClass: 水平尺寸类 (`UserInterfaceSizeClass`)
    ///   - compactColumns: 紧凑屏（iPhone）列数
    ///   - regularColumns: 宽屏（iPad）列数
    /// - Returns: 计算后的 GridItem 数组
    public static func gridColumns(
        for sizeClass: UserInterfaceSizeClass?,
        compactColumns: Int = 3,
        regularColumns: Int = 6,
        spacing: CGFloat = 16
    ) -> [GridItem] {
        let count = (sizeClass == .regular) ? regularColumns : compactColumns
        return Array(repeating: GridItem(.flexible(), spacing: spacing), count: count)
    }
}

/// iPad 居中大屏卡片容器 Modifier
public struct IPadContainerModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    public let maxWidth: CGFloat
    
    public init(maxWidth: CGFloat = 800) {
        self.maxWidth = maxWidth
    }
    
    public func body(content: Content) -> some View {
        if horizontalSizeClass == .regular {
            content
                .frame(maxWidth: maxWidth)
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            content
        }
    }
}

public extension View {
    /// 在 iPad / 常规宽度屏幕上限制内容最大宽度并自动居中
    func ipadAdaptiveContainer(maxWidth: CGFloat = 800) -> some View {
        self.modifier(IPadContainerModifier(maxWidth: maxWidth))
    }
}
