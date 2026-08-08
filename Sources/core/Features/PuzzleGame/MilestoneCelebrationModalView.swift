import SwiftUI

/// 每 10 关小通关金榜题名激励与微信/朋友圈捷报海报弹窗
public struct MilestoneCelebrationModalView: View {
    public let completedCount: Int
    public let currentStageName: String
    public let onDismiss: () -> Void
    public let onNextLevel: (() -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    @State private var timestampString: String = ""
    
    public init(
        completedCount: Int,
        currentStageName: String,
        onDismiss: @escaping () -> Void,
        onNextLevel: (() -> Void)? = nil
    ) {
        self.completedCount = completedCount
        self.currentStageName = currentStageName
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
                        title: "分享金榜题名捷报 (微信/朋友圈)",
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
        }
        .onAppear {
            generateTimestamp()
            SoundManager.shared.playSuccessSound()
        }
    }
    
    private var posterCardView: some View {
        PaperCardView(borderColor: Color.cloudGold) {
            VStack(spacing: 16) {
                // 顶栏：金榜题名皇冠标头
                HStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.title2)
                        .foregroundColor(.cloudGold)
                    Text("【金榜题名 · 小通关捷报】")
                        .font(.system(.title3, design: .serif))
                        .bold()
                        .foregroundColor(.cinnabarRed)
                    Image(systemName: "crown.fill")
                        .font(.title2)
                        .foregroundColor(.cloudGold)
                }
                .padding(.top, 6)
                
                Divider()
                
                HStack(spacing: 20) {
                    // 左侧：朱砂大印章 + 已解关数
                    VStack(spacing: 8) {
                        ChineseSealView(
                            text: "金榜\n题名",
                            isUnlocked: true,
                            size: 80,
                            imageName: nil
                        )
                        
                        Text("已解破 \(completedCount) 关")
                            .font(.system(.headline, design: .serif))
                            .bold()
                            .foregroundColor(.cinnabarRed)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("称号：\(currentStageName)")
                            .font(.system(.subheadline, design: .serif))
                            .bold()
                            .foregroundColor(.xuanBlack)
                        
                        Text("“小试牛刀！博通经史，才高八斗。功名顺遂，神兽伴学护航！”")
                            .font(.system(.footnote, design: .serif))
                            .foregroundColor(.gray)
                            .lineSpacing(4)
                    }
                }
                .padding(.vertical, 8)
                
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
                        Text("《甪端字游》App Store 正式版")
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
                    Text("《甪端字游》印")
                        .font(.system(size: 11, weight: .bold, design: .serif))
                        .foregroundColor(.cinnabarRed.opacity(0.8))
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
    
    private func shareMilestonePoster() {
        let shareText = "【甪端字游·金榜题名捷报】我已成功解破 \(completedCount) 关古风字游！题名时间：\(timestampString)。快来一起体验《甪端字游》！App Store 下载地址：https://apps.apple.com/us/app/%E7%94%AA%E7%AB%AF/id6799431765"
        ShareSheetHelper.share(items: [shareText])
    }
}
