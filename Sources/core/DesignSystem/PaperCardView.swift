import SwiftUI

public struct PaperCardView<Content: View>: View {
    public let content: Content
    public let cornerRadius: CGFloat
    public let borderColor: Color
    
    public init(
        cornerRadius: CGFloat = 16,
        borderColor: Color = Color.borderAncient,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(16)
            .background(Color.paperWhite)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: 1.5)
            )
            .shadow(color: Color.xuanBlack.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}
