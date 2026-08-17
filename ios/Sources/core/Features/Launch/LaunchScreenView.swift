import SwiftUI

/// 【神兽甪端伴学】App 启动欢迎页
public struct LaunchScreenView: View {
    @Binding var isPresented: Bool
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    private var luDuanImage: Image {
        #if canImport(UIKit)
        if let url = Bundle.module.url(forResource: "luDuan_mascot_user", withExtension: "png") ??
                     Bundle.module.url(forResource: "luDuan_splash_banner", withExtension: "jpg", subdirectory: "shared/data/badges"),
           let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        if let uiImage = UIImage(named: "luDuan_mascot_user") ?? UIImage(named: "luDuan_splash_banner") {
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
                    
                    luDuanImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 220, height: 220)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.cloudGold, lineWidth: 4))
                        .shadow(color: Color.cloudGold.opacity(0.3), radius: 10)
                }
                .padding(.top, 20)
                
                VStack(spacing: 6) {
                    // 主标题：文绉绉（大字，与下方"甪端字游"四字宽度对齐）
                    Text("文 绉 绉")
                        .font(.system(size: 64, weight: .bold, design: .serif))
                        .foregroundColor(.bambooGreen)
                        .kerning(8)
                        .frame(width: 266) // 4字×58 + 3×6 spacing = 250，微调居中
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)

                    HStack(spacing: 6) {
                        let titlePairs: [(String, String)] = [("lù", "甪"), ("duān", "端"), ("zì", "字"), ("yóu", "游")]
                        ForEach(titlePairs, id: \.0) { pinyin, hanzi in
                            VStack(spacing: 4) {
                                Text(pinyin)
                                    .font(.system(size: 16, weight: .bold, design: .serif))
                                    .foregroundColor(.cloudGold)
                                Text(hanzi)
                                    .font(.system(size: 42, weight: .bold, design: .serif))
                                    .foregroundColor(.cinnabarRed)
                            }
                            .frame(width: 58)
                        }
                    }
                    
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
