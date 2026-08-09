import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// 每 10 关小通关金榜题名激励与微信/朋友圈捷报海报弹窗
public struct MilestoneCelebrationModalView: View {
    public let completedCount: Int
    public let currentStageName: String
    public let lastLevel: LevelModel?
    public let onDismiss: () -> Void
    public let onNextLevel: (() -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    @State private var timestampString: String = ""
    @State private var fireworksShow: FireworksShow? = nil
    
    public init(
        completedCount: Int,
        currentStageName: String,
        lastLevel: LevelModel? = nil,
        onDismiss: @escaping () -> Void,
        onNextLevel: (() -> Void)? = nil
    ) {
        self.completedCount = completedCount
        self.currentStageName = currentStageName
        self.lastLevel = lastLevel
        self.onDismiss = onDismiss
        self.onNextLevel = onNextLevel
    }
    
    public var body: some View {
        ZStack {
            Color.paperWhite.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                // 捷报海报卡片 (带时间戳)
                posterCardView
                
                Spacer()
                
                // 操作按钮组：分享微信捷报 + 继续闯关
                VStack(spacing: 12) {
                    AncientButtonView(
                        title: "分享捷报",
                        iconName: "square.and.arrow.up.fill",
                        style: .primary
                    ) {
                        shareMilestonePoster()
                    }
                    
                    Button(action: {
                        if let nextAction = onNextLevel {
                            nextAction()
                        } else {
                            onDismiss()
                        }
                        dismiss()
                    }) {
                        Text("继续勇闯下一关 >")
                            .font(.system(.subheadline, design: .serif))
                            .bold()
                            .foregroundColor(.cinnabarRed)
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .ipadAdaptiveContainer(maxWidth: 680)

            if let show = fireworksShow {
                FireworksCelebrationView(show: show)
            }
        }
        .onAppear {
            generateTimestamp()
            SoundManager.shared.playSuccessSound()
            fireworksShow = FireworksShow(style: FireworksStyle.random())
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { fireworksShow = nil }
        }
    }
    
    private var posterCardView: some View {
        PaperCardView(borderColor: Color.cloudGold) {
            VStack(spacing: 16) {
                // 顶栏：APP 图标 + 甪端文案
                HStack(spacing: 12) {
                    appIconImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 81, height: 81)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.cloudGold, lineWidth: 2))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("《甪端字游》")
                            .font(.system(.headline, design: .serif))
                            .bold()
                            .foregroundColor(.cinnabarRed)
                        Text("神兽甪端伴学 · 万关典籍古风手游")
                            .font(.system(size: 11, weight: .medium, design: .serif))
                            .foregroundColor(.gray)
                        Text("“通解百家语言，专守千古书案”")
                            .font(.system(size: 10, weight: .medium, design: .serif))
                            .foregroundColor(.cloudGold)
                    }
                    Spacer()
                }
                .padding(.top, 6)
                
                Divider()
                if let lvl = lastLevel {
                    VStack(alignment: .leading, spacing: 6) {

                        
                        Text("“\(lvl.story)”")
                            .font(.system(size: 17, weight: .semibold, design: .serif))
                            .foregroundColor(.xuanBlack)
                            .lineSpacing(4)
                            .lineLimit(3)
                        
                        HStack {
                            Spacer()
                            Text("—— 出处：\(lvl.source)")
                                .font(.system(size: 11, weight: .bold, design: .serif))
                                .foregroundColor(.cinnabarRed)
                        }
                    }
                    .padding(10)
                    .background(Color.bambooGreen.opacity(0.08))
                    .cornerRadius(8)
                }
                
                Divider()
                
                // App Store 官方二维码与下载区域
                HStack(spacing: 12) {
                    QRCodeView(urlString: "https://apps.apple.com/us/app/%E7%94%AA%E7%AB%AF/id6799431765")
                        .frame(width: 72, height: 72)
                        .padding(4)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color.cloudGold, lineWidth: 1.5)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("《甪端字游》App Store下载")
                            .font(.system(size: 13, weight: .bold, design: .serif))
                            .foregroundColor(.cinnabarRed)
                        
                        Text("扫码或搜索下载 · 体验神兽伴学与典籍手游")
                            .font(.system(size: 11, weight: .medium, design: .serif))
                            .foregroundColor(.xuanBlack)
                        
                        Text("https://apps.apple.com/us/app/%E7%94%AA%E7%AB%AF/id6799431765")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.blue)
                            .lineLimit(1)
                    }
                }
                .padding(8)
                .background(Color.cloudGold.opacity(0.08))
                .cornerRadius(10)
                
                // 底部时间戳与手游水印
                HStack {
                    Text("📅 题名时间：\(timestampString)")
                        .font(.system(size: 11, weight: .bold, design: .serif))
                        .foregroundColor(.gray)
                    Spacer()
                    ChineseSealView(text: "甪端\n学游", isUnlocked: true, size: 36, imageName: nil)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func generateTimestamp() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        self.timestampString = formatter.string(from: Date())
    }

    private var appIconImage: Image {
        #if canImport(UIKit)
        if let url = Bundle.module.url(forResource: "luDuan_mascot_user", withExtension: "png"),
           let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        #endif
        return Image(systemName: "crown.fill")
    }
    
    @MainActor
    private func shareMilestonePoster() {
        let shareText = "【甪端字游】我已累计通关 \(completedCount) 词古风字游！神兽甪端伴学，万关典籍名篇。快来一起体验《甪端字游》！App Store下载：https://apps.apple.com/us/app/%E7%94%AA%E7%AB%AF/id6799431765"
        
        #if canImport(UIKit)
        let posterView = posterCardView
        
        var shareItems: [Any] = [shareText]
        if let image = ShareSheetHelper.renderViewToImage(posterView, width: 380, height: 680) {
            shareItems.insert(image, at: 0)
        }
        ShareSheetHelper.share(items: shareItems)
        #else
        ShareSheetHelper.share(items: [shareText])
        #endif
    }
}
