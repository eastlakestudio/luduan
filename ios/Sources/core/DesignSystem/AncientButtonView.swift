import SwiftUI

public struct AncientButtonView: View {
    public let title: String
    public let iconName: String?
    public let style: ButtonStyleType
    public let action: () -> Void
    
    public enum ButtonStyleType {
        case primary
        case secondary
        case gold
    }
    
    public init(
        title: String,
        iconName: String? = nil,
        style: ButtonStyleType = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.iconName = iconName
        self.style = style
        self.action = action
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: return Color.cinnabarRed
        case .secondary: return Color.bambooGreen
        case .gold: return Color.cloudGold
        }
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .font(.headline)
                }
                Text(title)
                    .font(.system(.body, design: .serif))
                    .bold()
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(backgroundColor)
            .cornerRadius(12)
            .shadow(color: backgroundColor.opacity(0.4), radius: 6, x: 0, y: 3)
        }
    }
}
