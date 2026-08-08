import SwiftUI

public struct BadgeGalleryView: View {
    @EnvironmentObject private var repository: GameDataRepository
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var selectedCategory: BadgeCategory? = nil
    @State private var selectedBadge: BadgeModel? = nil
    
    public init() {}
    
    private var filteredBadges: [BadgeModel] {
        if let category = selectedCategory {
            return repository.badges.filter { $0.category == category }
        } else {
            return repository.badges
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.paperWhite.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // 解锁进度条 Header
                    progressHeader
                    
                    // 分类 Tab 切换
                    categoryPicker
                    
                    // 勋章图鉴 Grid
                    ScrollView {
                        let columns = AdaptiveLayoutHelper.gridColumns(
                            for: horizontalSizeClass,
                            compactColumns: 3,
                            regularColumns: 6,
                            spacing: 20
                        )
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(filteredBadges) { badge in
                                let isUnlocked = repository.isBadgeUnlocked(badge.id)
                                
                                Button(action: {
                                    selectedBadge = badge
                                }) {
                                    VStack(spacing: 8) {
                                        // 肖像图与印章双显模块
                                        HStack(spacing: -14) {
                                            // 1. 名士卡通肖像图
                                            ChineseSealView(text: badge.sealText, isUnlocked: isUnlocked, size: 58, imageName: badge.imageName)
                                            
                                            // 2. 古风朱砂印章
                                            ChineseSealView(text: badge.sealText, isUnlocked: isUnlocked, size: 48, imageName: nil)
                                        }
                                        
                                        Text(badge.name)
                                            .font(.system(.caption, design: .serif))
                                            .bold()
                                            .foregroundColor(isUnlocked ? .xuanBlack : .gray)
                                    }
                                }
                            }
                        }
                        .padding(20)
                    }
                }
                .ipadAdaptiveContainer(maxWidth: 840)
            }
            .navigationTitle("勋章馆")
            .inlineNavigationBarTitle()
            .toolbar {
                ToolbarItem(placement: .adaptiveTrailing) {
                    Button("关闭") { dismiss() }
                        .foregroundColor(.cinnabarRed)
                }
            }
            .sheet(item: $selectedBadge) { badge in
                badgeDetailModal(for: badge)
            }
        }
    }
    
    private var progressHeader: some View {
        PaperCardView {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "seal.fill")
                            .font(.system(size: 15))
                            .foregroundColor(.cinnabarRed)
                        Text("勋章解锁进度")
                            .font(.system(.subheadline, design: .serif))
                            .bold()
                            .foregroundColor(.xuanBlack)
                        Image(systemName: "seal.fill")
                            .font(.system(size: 15))
                            .foregroundColor(.cloudGold)
                    }
                    
                    Text("通过解锁典故与诗词关卡获得古风特色印章")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                
                Text("\(repository.userProgress.unlockedBadgeIds.count) / \(repository.badges.count)")
                    .font(.system(.title3, design: .serif))
                    .bold()
                    .foregroundColor(.cinnabarRed)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                categoryChip(title: "全部", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                
                ForEach(BadgeCategory.allCases) { category in
                    categoryChip(title: category.rawValue, isSelected: selectedCategory == category) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func categoryChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(.footnote, design: .serif))
                .bold()
                .foregroundColor(isSelected ? .white : .xuanBlack)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.cinnabarRed : Color.borderAncient.opacity(0.3))
                .cornerRadius(16)
        }
    }
    
    private func badgeDetailModal(for badge: BadgeModel) -> some View {
        let isUnlocked = repository.isBadgeUnlocked(badge.id)
        
        return ZStack {
            Color.paperWhite.ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    VStack(spacing: 6) {
                        ChineseSealView(text: badge.sealText, isUnlocked: isUnlocked, size: 84, imageName: badge.imageName)
                        Text("人物肖像")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    VStack(spacing: 6) {
                        ChineseSealView(text: badge.sealText, isUnlocked: isUnlocked, size: 84, imageName: nil)
                        Text("古风朱印")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 30)
                
                Text(badge.name)
                    .font(.system(.title2, design: .serif))
                    .bold()
                    .foregroundColor(.xuanBlack)
                
                Text(isUnlocked ? "【已解锁收集】" : "【未解锁】")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(isUnlocked ? .bambooGreen : .gray)
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("勋章描述")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(badge.description)
                            .font(.system(.body, design: .serif))
                            .foregroundColor(.xuanBlack)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("解锁方式")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(badge.requirementDescription)
                            .font(.system(.subheadline, design: .serif))
                            .foregroundColor(.cinnabarRed)
                    }
                }
                .padding(20)
                .background(Color.cardSurface)
                .cornerRadius(16)
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
}
