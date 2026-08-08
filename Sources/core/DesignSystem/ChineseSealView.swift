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
                // 卡通名士肖像印章模式
                ZStack {
                    image
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(1.25)
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .strokeBorder(isUnlocked ? Color.cloudGold : Color.gray.opacity(0.4), lineWidth: 3)
                        )
                        .grayscale(isUnlocked ? 0.0 : 1.0)
                        .opacity(isUnlocked ? 1.0 : 0.45)
                    
                    if !isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: size * 0.3))
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                    }
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
        #if canImport(UIKit)
        if let uiImage = UIImage(named: name, in: .module, compatibleWith: nil) {
            return Image(uiImage: uiImage)
        }
        if let uiImage = UIImage(named: name) {
            return Image(uiImage: uiImage)
        }
        // 读取 Resources 根路径与 BadgeImages 目录
        if let url = Bundle.module.url(forResource: name, withExtension: "jpg") ??
                     Bundle.module.url(forResource: name, withExtension: "jpg", subdirectory: "BadgeImages"),
           let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        if let url = Bundle.module.url(forResource: name, withExtension: "png") ??
                     Bundle.module.url(forResource: name, withExtension: "png", subdirectory: "BadgeImages"),
           let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        #endif
        return nil
    }
}
