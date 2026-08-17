import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// 勋章解锁捷报分享弹窗（与安卓 BadgeShareDialog 对齐：徽章图 + 勋章名号 + 随机原文 + 二维码）
public struct BadgeUnlockShareView: View {
    public let badge: BadgeModel
    public let fallbackLevel: LevelModel
    public let onDismiss: () -> Void
    
    @EnvironmentObject private var repository: GameDataRepository
    @Environment(\.dismiss) private var dismiss
    @State private var selectedWord: ClassicalSeedItem? = nil
    
    public init(
        badge: BadgeModel,
        fallbackLevel: LevelModel,
        onDismiss: @escaping () -> Void
    ) {
        self.badge = badge
        self.fallbackLevel = fallbackLevel
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        ZStack {
            Color.paperWhite.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                posterCardView
                
                Spacer()
                
                VStack(spacing: 12) {
                    AncientButtonView(
                        title: "分享捷报",
                        iconName: "square.and.arrow.up.fill",
                        style: .primary
                    ) {
                        shareBadgePoster()
                    }
                    
                    Button(action: closeAction) {
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
            if selectedWord == nil {
                selectedWord = pickRandomWord()
            }
            SoundManager.shared.playSuccessSound()
        }
    }
    
    /// 从该勋章词池随机选一条（优先已学会的词，与安卓 BadgeShareDialog 逻辑一致）
    private func pickRandomWord() -> ClassicalSeedItem? {
        let words = repository.badgeWords(for: badge.id)
        let learned = words.filter { repository.userProgress.learnedPhrases.contains($0.phrase) }
        let pool = learned.isEmpty ? words : learned
        return pool.randomElement()
    }
    
    private var displaySource: String {
        selectedWord?.source ?? fallbackLevel.source
    }
    
    private var displayStory: String {
        selectedWord?.story ?? fallbackLevel.story
    }
    
    private func closeAction() {
        dismiss()
        onDismiss()
    }
    
    private var posterCardView: some View {
        PaperCardView(borderColor: Color.cloudGold) {
            VStack(spacing: 14) {
                // 顶栏：APP 图标 + 品牌文案
                HStack(spacing: 12) {
                    appIconImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.cloudGold, lineWidth: 1.5))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("《文绉绉-甪端》")
                            .font(.system(.headline, design: .serif))
                            .bold()
                            .foregroundColor(.cinnabarRed)
                        Text("神兽甪端伴学 · 万关典籍古风手游")
                            .font(.system(size: 10, weight: .medium, design: .serif))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.top, 6)
                
                Divider()
                
                // 徽章印章 + 名号
                VStack(spacing: 10) {
                    ChineseSealView(
                        text: badge.sealText,
                        isUnlocked: true,
                        size: 96,
                        imageName: badge.imageName
                    )
                    
                    Text("勋章解锁 · \(badge.name)")
                        .font(.system(size: 19, weight: .bold, design: .serif))
                        .foregroundColor(.cinnabarRed)
                }
                .padding(.vertical, 4)
                
                Divider()
                
                // 该勋章词池中随机一条词句的原文
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(displayStory.prefix(100)) + (displayStory.count > 100 ? "…" : ""))
                        .font(.system(size: 13, weight: .semibold, design: .serif))
                        .foregroundColor(.xuanBlack)
                        .lineSpacing(6)
                    
                    HStack {
                        Spacer()
                        Text("—— 出处：\(displaySource)")
                            .font(.system(size: 11, weight: .bold, design: .serif))
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Color.bambooGreen.opacity(0.08))
                .cornerRadius(8)
                
                // 双平台二维码下载区（与安卓一致：安卓下载 / 苹果应用 / 官网）
                HStack(spacing: 12) {
                    qrItem(
                        urlString: "https://eastlakestudio.github.io/luduan/luduan-v1.1.0.apk",
                        label: "安卓下载"
                    )
                    qrItem(
                        urlString: "https://apps.apple.com/app/id6799431765",
                        label: "苹果应用"
                    )
                    qrItem(
                        urlString: "https://eastlakestudio.github.io/luduan/",
                        label: "官网"
                    )
                }
                .padding(.vertical, 8)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func qrItem(urlString: String, label: String) -> some View {
        VStack(spacing: 4) {
            QRCodeView(urlString: urlString)
                .frame(width: 64, height: 64)
                .padding(3)
                .background(Color.white)
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Color.cloudGold.opacity(0.6), lineWidth: 1)
                )
            
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .serif))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
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
    private func shareBadgePoster() {
        let shareText = "【文绉绉-甪端】我解锁了勋章「\(badge.name)」！"
        
        #if canImport(UIKit)
        let cardContent = posterCardView
            .padding(4)
            .frame(width: 390)
            .background(Color.paperWhite)
        
        let renderer = ImageRenderer(content: cardContent)
        renderer.scale = 2
        
        var shareItems: [Any] = [shareText]
        if let image = renderer.uiImage {
            shareItems.insert(image, at: 0)
        }
        DispatchQueue.main.async {
            ShareSheetHelper.share(items: shareItems)
        }
        #else
        ShareSheetHelper.share(items: [shareText])
        #endif
    }
}
