import SwiftUI

/// 【神兽甪端伴学】App 启动欢迎页
public struct LaunchScreenView: View {
    @Binding var isPresented: Bool
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    private var luduanImage: Image {
        #if canImport(UIKit)
        if let url = Bundle.module.url(forResource: "luduan_mascot_user", withExtension: "png") ??
                     Bundle.module.url(forResource: "luduan_splash_banner", withExtension: "jpg", subdirectory: "BadgeImages"),
           let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        if let uiImage = UIImage(named: "luduan_mascot_user") ?? UIImage(named: "luduan_splash_banner") {
            return Image(uiImage: uiImage)
        }
        #endif
        return Image(systemName: "crown.fill")
    }
    
    public var body: some View {
        ZStack {
            Color.paperWhite.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                // 甪端神兽主视觉高清大图
                ZStack {
                    Circle()
                        .fill(Color.cloudGold.opacity(0.18))
                        .frame(width: 240, height: 240)
                    
                    luduanImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 220, height: 220)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.cloudGold, lineWidth: 4))
                        .shadow(color: Color.cloudGold.opacity(0.3), radius: 10)
                }
                .padding(.top, 20)
                
                VStack(spacing: 6) {
                    Text("lù  duān  zì  yóu")
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .foregroundColor(.cloudGold)
                        .tracking(6)
                    
                    Text("《甪端字游》")
                        .font(.system(size: 42, weight: .bold, design: .serif))
                        .foregroundColor(.cinnabarRed)
                    
                    Text("神兽甪端伴学 · 典籍名篇关卡古风手游")
                        .font(.system(size: 17, weight: .bold, design: .serif))
                        .foregroundColor(.bambooGreen)
                    
                    Text("日行万八千里 · 通解百家语言 · 专守千古书案")
                        .font(.system(size: 14, weight: .medium, design: .serif))
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
                
                Spacer()
                
                AncientButtonView(title: "开启甪端字游之旅 >", iconName: "sparkles", style: .primary) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
}
