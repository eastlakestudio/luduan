import SwiftUI

public struct CircularProgressGaugeView: View {
    public let completedCount: Int
    public let totalCount: Int
    public let size: CGFloat
    public let lineWidth: CGFloat
    public let tintColor: Color
    
    public init(
        completedCount: Int,
        totalCount: Int,
        size: CGFloat = 64,
        lineWidth: CGFloat = 6,
        tintColor: Color = .bambooGreen
    ) {
        self.completedCount = completedCount
        self.totalCount = totalCount
        self.size = size
        self.lineWidth = lineWidth
        self.tintColor = tintColor
    }
    
    private var progress: Double {
        guard totalCount > 0 else { return 0.0 }
        return min(1.0, max(0.0, Double(completedCount) / Double(totalCount)))
    }
    
    public var body: some View {
        ZStack {
            // 底环背景
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: lineWidth)
            
            // 弧形进度线条
            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(
                    LinearGradient(
                        colors: [tintColor, tintColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
            
            // 环形图表中心文字
            VStack(spacing: 1) {
                Text("\(completedCount)/\(totalCount)")
                    .font(.system(size: size * 0.22, weight: .bold, design: .serif))
                    .foregroundColor(.xuanBlack)
                Text("\(Int(progress * 100))%")
                    .font(.system(size: size * 0.16, weight: .medium, design: .serif))
                    .foregroundColor(.gray)
            }
        }
        .frame(width: size, height: size)
    }
}
