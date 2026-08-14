import SwiftUI

/// 支持【灰色、半灰半彩双色分断、全彩】3 种通关状态的 80pt 超大古风勋章视图
public struct ThreeStateBadgeView: View {
    public let sealText: String
    public let imageName: String?
    public let progressRatio: Double // 0.0 ~ 1.0
    public let size: CGFloat
    
    public init(
        sealText: String,
        imageName: String? = nil,
        progressRatio: Double,
        size: CGFloat = 80
    ) {
        self.sealText = sealText
        self.imageName = imageName
        self.progressRatio = min(1.0, max(0.0, progressRatio))
        self.size = size
    }
    
    public var body: some View {
        ZStack {
            if progressRatio >= 1.0 {
                // 100% 已完全通关：全彩亮丽朱砂印章
                ChineseSealView(text: sealText, isUnlocked: true, size: size, imageName: imageName)
            } else if progressRatio <= 0.0 {
                // 0% 未开始：全灰蒙版
                ChineseSealView(text: sealText, isUnlocked: false, size: size, imageName: imageName)
            } else {
                // 1% ~ 99% 通关中：半灰半彩双色分断 (左半部分彩色发光，右半部分灰色遮罩)
                ZStack {
                    // 底层：灰色印章
                    ChineseSealView(text: sealText, isUnlocked: false, size: size, imageName: imageName)
                    
                    // 顶层：彩色印章 + 左侧遮罩裁剪
                    ChineseSealView(text: sealText, isUnlocked: true, size: size, imageName: imageName)
                        .mask(
                            GeometryReader { geo in
                                Rectangle()
                                    .frame(width: geo.size.width * CGFloat(progressRatio), height: geo.size.height)
                                    .alignmentGuide(.leading) { _ in 0 }
                            }
                        )
                }
            }
        }
        .frame(width: size, height: size)
    }
}
