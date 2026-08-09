import SwiftUI

/// 《甪端字游》社交营销广告级分享海报卡片组件
public struct SharePosterCardView: View {
    public let level: LevelModel
    public let completedCount: Int?
    
    public init(level: LevelModel, completedCount: Int? = nil) {
        self.level = level
        self.completedCount = completedCount
    }
    
    private var cleanBookTitle: String {
        let raw = level.source.replacingOccurrences(of: "《", with: "").replacingOccurrences(of: "》", with: "")
        return "《\(raw)》"
    }

    public var body: some View {
        PaperCardView(borderColor: Color.cloudGold) {
            VStack(spacing: 16) {
                // 1. 顶部品牌与“甪端学游”中国传统朱砂印章
                HStack(spacing: 14) {
                    ChineseSealView(
                        text: "甪端\n学游",
                        isUnlocked: true,
                        size: 52,
                        imageName: nil
                    )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("lù  duān  xué  yóu")
                            .font(.system(size: 11, weight: .bold, design: .serif))
                            .foregroundColor(.cloudGold)
                            .tracking(3)
                        
                        Text("《甪端字游》")
                            .font(.system(size: 22, weight: .bold, design: .serif))
                            .foregroundColor(.cinnabarRed)
                    }
                    
                    Spacer()
                    
                    if let count = completedCount {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("金榜已破")
                                .font(.system(size: 10, weight: .bold, design: .serif))
                                .foregroundColor(.gray)
                            Text("\(count) 关")
                                .font(.system(size: 18, weight: .bold, design: .serif))
                                .foregroundColor(.cinnabarRed)
                        }
                    }
                }
                .padding(.top, 4)
                
                Divider()
                
                // 2. 学过的典籍名称与成语名句展示
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        Image(systemName: "book.closed.fill")
                            .font(.subheadline)
                            .foregroundColor(.bambooGreen)
                        Text("典籍出处：")
                            .font(.system(size: 13, weight: .bold, design: .serif))
                            .foregroundColor(.gray)
                        Text(cleanBookTitle)
                            .font(.system(size: 15, weight: .bold, design: .serif))
                            .foregroundColor(.bambooGreen)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.bambooGreen.opacity(0.1))
                    .cornerRadius(8)
                    
                    HStack(spacing: 8) {
                        Text("解破名句：")
                            .font(.system(size: 13, weight: .bold, design: .serif))
                            .foregroundColor(.gray)
                        Text("【\(level.targetPhrase)】")
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .foregroundColor(.cinnabarRed)
                    }
                    .padding(.top, 2)
                    
                    // 核心：本次闯关古文原文节选
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "quote.opening")
                                .font(.caption)
                                .foregroundColor(.cloudGold)
                            Text("本次闯关古文原文节选")
                                .font(.system(size: 12, weight: .bold, design: .serif))
                                .foregroundColor(.cloudGold)
                        }
                        
                        Text("“\(level.story)”")
                            .font(.system(size: 15, weight: .bold, design: .serif))
                            .foregroundColor(.xuanBlack)
                            .lineSpacing(6)
                        
                        HStack {
                            Spacer()
                            Text("—— 出处：\(cleanBookTitle)")
                                .font(.system(size: 11, weight: .bold, design: .serif))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(12)
                    .background(Color.cloudGold.opacity(0.12))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.cloudGold.opacity(0.4), lineWidth: 1)
                    )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("【字词释义】")
                            .font(.system(size: 11, weight: .bold, design: .serif))
                            .foregroundColor(.bambooGreen)
                        Text(level.annotation)
                            .font(.system(size: 14, weight: .bold, design: .serif))
                            .foregroundColor(.xuanBlack)
                            .lineSpacing(4)
                    }
                    .padding(10)
                    .background(Color.bambooGreen.opacity(0.08))
                    .cornerRadius(8)
                }
                
                Divider()
                
                // 3. 广告裂变 CoreImage 高清 App Store 二维码区
                HStack(spacing: 12) {
                    QRCodeView(urlString: "https://apps.apple.com/us/app/%E7%94%AA%E7%AB%AF/id6799431765")
                        .frame(width: 70, height: 70)
                        .padding(4)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color.cloudGold, lineWidth: 1.5)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.cloudGold)
                            Text("《甪端字游》App Store 正式版")
                                .font(.system(size: 13, weight: .bold, design: .serif))
                                .foregroundColor(.cinnabarRed)
                        }
                        
                        Text("扫码体验神兽伴学 · 畅游万关国学典籍")
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
            }
        }
    }
}
