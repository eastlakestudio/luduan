import SwiftUI

public struct BadgeGalleryView: View {
    @EnvironmentObject private var repository: GameDataRepository
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var selectedCategory: BadgeCategory? = nil
    @State private var selectedBadge: BadgeModel? = nil
    
    public init() {}
    
    private var displayedCategories: [BadgeCategory] {
        [.character, .academic, .classics]
    }
    
    private var allValidBadges: [BadgeModel] {
        repository.badges.filter { $0.category != .practical }
    }
    
    private var filteredBadges: [BadgeModel] {
        if let category = selectedCategory {
            return allValidBadges.filter { $0.category == category }
        } else {
            return allValidBadges
        }
    }
    
    private var unlockedCount: Int {
        let validIds = Set(allValidBadges.map { $0.id })
        return repository.userProgress.unlockedBadgeIds.intersection(validIds).count
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
                                let isIllustrated = (badge.category == .character || badge.category == .academic) && ChineseSealView.hasCartoonImage(named: badge.imageName, text: badge.name)
                                let sealText = (badge.category == .classics) ? bookSealText(from: badge.name) : badge.sealText
                                
                                Button(action: {
                                    selectedBadge = badge
                                }) {
                                    VStack(spacing: 8) {
                                        if isIllustrated {
                                            // 人物/功名肖像图 + 右下角精巧朱印角标
                                            ZStack(alignment: .bottomTrailing) {
                                                ChineseSealView(text: sealText, isUnlocked: isUnlocked, size: 68, imageName: badge.imageName ?? badge.name)
                                                
                                                ChineseSealView(text: sealText, isUnlocked: isUnlocked, size: 26, imageName: nil)
                                                    .offset(x: 4, y: 4)
                                            }
                                        } else {
                                            // 典籍名篇书名古风朱砂印章
                                            ChineseSealView(text: sealText, isUnlocked: isUnlocked, size: 66, imageName: nil)
                                        }
                                        
                                        Text(badge.name)
                                            .font(.system(.caption, design: .serif))
                                            .bold()
                                            .foregroundColor(isUnlocked ? .xuanBlack : .gray)
                                            .lineLimit(1)
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
                
                Text("\(unlockedCount) / \(allValidBadges.count)")
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
                
                ForEach(displayedCategories) { category in
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
        let isIllustrated = (badge.category == .character || badge.category == .academic) && ChineseSealView.hasCartoonImage(named: badge.imageName, text: badge.name)
        let sealText = (badge.category == .classics) ? bookSealText(from: badge.name) : badge.sealText
        
        return ZStack {
            Color.paperWhite.ignoresSafeArea()
            
            VStack(spacing: 20) {
                if isIllustrated {
                    HStack(spacing: 24) {
                        VStack(spacing: 8) {
                            ChineseSealView(text: sealText, isUnlocked: isUnlocked, size: 130, imageName: badge.imageName ?? badge.name)
                            Text("专属图鉴")
                                .font(.system(.caption, design: .serif))
                                .foregroundColor(.gray)
                        }
                        
                        VStack(spacing: 8) {
                            ChineseSealView(text: sealText, isUnlocked: isUnlocked, size: 130, imageName: nil)
                            Text("古风朱印")
                                .font(.system(.caption, design: .serif))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 24)
                } else {
                    VStack(spacing: 8) {
                        ChineseSealView(text: sealText, isUnlocked: isUnlocked, size: 140, imageName: nil)
                        Text("典籍御印")
                            .font(.system(.caption, design: .serif))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 24)
                }
                
                Text(badge.name)
                    .font(.system(.title, design: .serif))
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
    
    private func bookSealText(from name: String) -> String {
        let clean = name.replacingOccurrences(of: "《", with: "").replacingOccurrences(of: "》", with: "").trimmingCharacters(in: .whitespaces)
        if clean.count <= 2 {
            return clean
        } else if clean.count == 3 {
            let first2 = String(clean.prefix(2))
            let last1 = String(clean.suffix(1))
            return "\(first2)\n\(last1)"
        } else if clean.count == 4 {
            let first2 = String(clean.prefix(2))
            let last2 = String(clean.dropFirst(2).prefix(2))
            return "\(first2)\n\(last2)"
        } else {
            let first2 = String(clean.prefix(2))
            let next2 = String(clean.dropFirst(2).prefix(2))
            return "\(first2)\n\(next2)"
        }
    }
}
