import SwiftUI

public struct StoryCardModalView: View {
    public let level: LevelModel
    public let onDismiss: () -> Void
    public let onNextLevel: ((LevelModel) -> Void)?
    
    @EnvironmentObject private var repository: GameDataRepository
    
    public init(
        level: LevelModel,
        onDismiss: @escaping () -> Void,
        onNextLevel: ((LevelModel) -> Void)? = nil
    ) {
        self.level = level
        self.onDismiss = onDismiss
        self.onNextLevel = onNextLevel
    }
    
    private var unlockedBadge: BadgeModel? {
        if let badgeId = level.rewardBadgeId {
            return repository.badges.first { $0.id == badgeId }
        }
        return nil
    }
    
    private var nextLevel: LevelModel? {
        repository.nextLevel(after: level)
    }
    
    public var body: some View {
        ZStack {
            Color.paperWhite.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // 顶部勋章获得与成功标识
                ZStack {
                    Circle()
                        .fill(Color.cloudGold.opacity(0.2))
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: "seal.fill")
                        .font(.system(size: 38))
                        .foregroundColor(.cinnabarRed)
                }
                .padding(.top, 16)
                
                Text("顺利解开典故名句！")
                    .font(.system(.title2, design: .serif))
                    .bold()
                    .foregroundColor(.xuanBlack)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // 目标成语/名句大字展示 (自适应网格排版，10 字自动 5x2 矩阵)
                        let chars = Array(level.targetPhrase).map { String($0) }
                        let colCount = chars.count <= 4 ? chars.count : (chars.count == 8 ? 4 : (chars.count == 10 ? 5 : min(chars.count, 5)))
                        let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: colCount)
                        
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(0..<chars.count, id: \.self) { idx in
                                let char = chars[idx]
                                let py = PinyinHelper.pinyin(for: char)
                                VStack(spacing: 2) {
                                    Text(py)
                                        .font(.system(size: 14, weight: .bold, design: .serif))
                                        .foregroundColor(.cinnabarRed.opacity(0.85))
                                    Text(char)
                                        .font(.system(size: 30, weight: .bold, design: .serif))
                                        .foregroundColor(.cinnabarRed)
                                }
                                .padding(.vertical, 4)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(Color.borderAncient.opacity(0.6), lineWidth: 1)
                                )
                            }
                        }
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.borderAncient, lineWidth: 1.5)
                        )
                        
                        // 注音与释义 (24pt 超大护眼大字)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("【字词释义】")
                                .font(.system(.headline, design: .serif))
                                .bold()
                                .foregroundColor(.bambooGreen)
                            Text(level.annotation)
                                .font(.system(size: 24, weight: .bold, design: .serif))
                                .foregroundColor(.xuanBlack)
                                .lineSpacing(10)
                        }
                        .padding(18)
                        .background(Color.bambooGreen.opacity(0.08))
                        .cornerRadius(12)
                        
                        // 历史典故古文原文 (23pt 超大护眼大字)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("【古文原文 / 典故故事】")
                                .font(.system(.headline, design: .serif))
                                .bold()
                                .foregroundColor(.cloudGold)
                            Text(level.story)
                                .font(.system(size: 23, weight: .bold, design: .serif))
                                .foregroundColor(.xuanBlack)
                                .lineSpacing(10)
                            
                            Text("—— 出处：\(level.source)")
                                .font(.system(size: 16, weight: .bold, design: .serif))
                                .foregroundColor(.gray)
                                .padding(.top, 4)
                        }
                        .padding(18)
                        .background(Color.cloudGold.opacity(0.08))
                        .cornerRadius(12)
                        
                        // 满 10 关才在「金榜题名捷报」中分享，单关不再弹出分享

                        
                        // 解锁百杰勋章提示
                        if let badge = unlockedBadge {
                            HStack(spacing: 12) {
                                ChineseSealView(text: badge.sealText, isUnlocked: true, size: 54, imageName: badge.imageName)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("已解锁新勋章：\(badge.name)")
                                        .font(.system(.headline, design: .serif))
                                        .bold()
                                        .foregroundColor(.cinnabarRed)
                                    Text(badge.description)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color.cinnabarRed.opacity(0.08))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                VStack(spacing: 10) {
                    if let next = nextLevel {
                        AncientButtonView(title: "进入下一关 >", iconName: "arrow.right.circle.fill", style: .primary) {
                            onNextLevel?(next)
                        }
                    } else {
                        AncientButtonView(title: "【\(level.theme.rawValue)】完美通关！关闭返回", iconName: "crown.fill", style: .gold) {
                            onDismiss()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}
