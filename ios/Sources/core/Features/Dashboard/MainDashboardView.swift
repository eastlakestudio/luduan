import SwiftUI

public struct MainDashboardView: View {
    @EnvironmentObject private var repository: GameDataRepository
    
    @Binding var pendingDeepLinkLevelId: String?
    
    @State private var selectedDimension: ThemeDimension = .academic
    @State private var activeGameLevel: LevelModel? = nil
    @State private var showingBadgeGallery = false
    @AppStorage(SoundManager.soundEnabledKey) private var soundEnabled = true
    
    private static var bannerCache: Image? = nil
    
    public init(pendingDeepLinkLevelId: Binding<String?> = .constant(nil)) {
        self._pendingDeepLinkLevelId = pendingDeepLinkLevelId
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.paperWhite.ignoresSafeArea()
                
                VStack(spacing: 14) {
                    // 自定义常驻古典顶栏（左上角：甪端字游，右上角：勋章馆）
                    dashboardTopBar
                    
                    // 顶栏 Header：Pet 形象与名号
                    headerBannerView
                    
                    // 三大通关主模式 Segmented Switcher
                    dimensionSegmentPicker
                    
                    // 地图关卡路线：按难度/年代由易到难纵向从上至下排列
                    ScrollView {
                        VStack(spacing: 16) {
                            switch selectedDimension {
                            case .academic:
                                academicModeCards
                            case .classics:
                                classicsModeCards
                            case .practical:
                                practicalModeCards
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                }
                .ipadAdaptiveContainer(maxWidth: 780)
            }
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
            .toolbar(.hidden, for: .navigationBar)
            #if os(iOS)
            .fullScreenCover(item: $activeGameLevel) { level in
                PuzzleGameView(level: level)
                    .id(level.id)
                    .environmentObject(repository)
            }
            #else
            .sheet(item: $activeGameLevel) { level in
                PuzzleGameView(level: level)
                    .id(level.id)
                    .environmentObject(repository)
            }
            #endif
            .sheet(isPresented: $showingBadgeGallery) {
                BadgeGalleryView()
                    .environmentObject(repository)
            }
            .onChange(of: pendingDeepLinkLevelId) { oldValue, newValue in
                guard let levelId = newValue else { return }
                if let level = repository.level(withId: levelId) {
                    activeGameLevel = level
                }
                pendingDeepLinkLevelId = nil
            }
        }
    }
    
    private var dashboardTopBar: some View {
        HStack {
            Text("文绉绉-甪端字游")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundColor(.xuanBlack)
            
            Spacer()
            
            Button(action: { showingBadgeGallery = true }) {
                HStack(spacing: 5) {
                    Image(systemName: "seal.fill")
                        .foregroundColor(.cinnabarRed)
                    Text("勋章馆")
                        .font(.system(.subheadline, design: .serif))
                        .bold()
                        .foregroundColor(.cinnabarRed)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Color.cinnabarRed.opacity(0.1))
                .cornerRadius(16)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    private var mascotBannerImage: Image {
        if let cached = Self.bannerCache { return cached }
        #if canImport(UIKit)
        if let url = Bundle.module.url(forResource: "luDuan_splash_banner", withExtension: "jpg") ??
                     Bundle.module.url(forResource: "luDuan_splash_banner", withExtension: "jpg", subdirectory: "shared/data/badges"),
           let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            let img = Image(uiImage: uiImage)
            Self.bannerCache = img
            return img
        }
        #endif
        return Image(systemName: "crown.fill")
    }

    private var headerBannerView: some View {
        PaperCardView(borderColor: Color.cloudGold) {
            HStack(spacing: 16) {
                // 甪端神兽伴学头像
                mascotBannerImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.cloudGold, lineWidth: 2))
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("神兽甪端伴学护航")
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .foregroundColor(.xuanBlack)
                    
                    Text("通解百家、神游千载")
                        .font(.system(size: 14.5, weight: .medium, design: .serif))
                        .foregroundColor(.xuanBlack.opacity(0.75))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("解破关数")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text("\(repository.userProgress.learnedPhrases.count)")
                        .font(.system(.title2, design: .serif))
                        .bold()
                        .foregroundColor(.cinnabarRed)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 6)
    }
    
    private var dimensionSegmentPicker: some View {
        HStack(spacing: 8) {
            ForEach(ThemeDimension.allCases) { dimension in
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedDimension = dimension
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: dimension.iconName)
                        Text(dimension.rawValue)
                    }
                    .font(.system(.subheadline, design: .serif))
                    .bold()
                    .foregroundColor(selectedDimension == dimension ? .white : .xuanBlack)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(selectedDimension == dimension ? Color.cinnabarRed : Color.cardSurface)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(selectedDimension == dimension ? Color.cinnabarRed : Color.borderAncient, lineWidth: 1.5)
                    )
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // ----------------------------------------------------
    // 1. 【学阶功名】模式：与勋章馆「功名学阶」一致（童生·上/中/下 … 帝师）
    // ----------------------------------------------------
    private var academicModeCards: some View {
        sectionCards(for: repository.badges.filter { $0.category == .academic })
    }
    
    private func sectionCards(for items: [BadgeModel]) -> some View {
        return LazyVStack(spacing: 16) {
            ForEach(items) { badge in
                badgeSectionCard(badge: badge)
            }
        }
    }

    private func badgeSectionCard(badge: BadgeModel) -> some View {
        let progress = repository.badgeProgressInfo(badge)
        let completed = progress.completed
        let count = progress.total
        let ratio = progress.ratio
        let isFreshPlay = repository.isThemeInFreshPlay(badge.id)

        let sealText: String
        let imageName: String?
        
        if badge.category == .classics {
            sealText = bookSealText(from: badge.name)
            imageName = nil
        } else {
            sealText = badge.sealText
            imageName = badge.imageName
        }

        return PaperCardView(borderColor: ratio >= 1.0 ? Color.cloudGold : Color.borderAncient) {
            HStack(spacing: 16) {
                ThreeStateBadgeView(
                    sealText: sealText,
                    imageName: imageName,
                    progressRatio: ratio,
                    size: 80
                )

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(badge.name)
                            .font(.system(.title3, design: .serif))
                            .bold()
                            .foregroundColor(.cinnabarRed)
                        Spacer()
                        
                        Button(action: {
                            repository.toggleFreshReplayMode(for: badge.id)
                        }) {
                            HStack(spacing: 3) {
                                Image(systemName: isFreshPlay ? "arrow.clockwise.circle.fill" : "arrow.clockwise.circle")
                                Text(isFreshPlay ? "全新模式" : "全新开发")
                            }
                            .font(.caption2)
                            .bold()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(isFreshPlay ? Color.bambooGreen.opacity(0.18) : Color.borderAncient.opacity(0.3))
                            .foregroundColor(isFreshPlay ? .bambooGreen : .xuanBlack.opacity(0.7))
                            .cornerRadius(10)
                        }
                        
                        Text("\(completed) / \(count) 词")
                            .font(.system(.subheadline, design: .serif))
                            .bold()
                            .foregroundColor(.gray)
                    }

                    Text(badge.description)
                        .font(.system(.footnote, design: .serif))
                        .foregroundColor(.xuanBlack)
                        .lineLimit(1)

                    ProgressView(value: ratio)
                        .tint(ratio >= 1.0 ? Color.cloudGold : Color.cinnabarRed)
                }
            }
        }
        .onTapGesture {
            repository.setActiveBadge(badge)
            let nextLevel = repository.levelForBadge(badge, skipCompleted: !isFreshPlay)
            activeGameLevel = nextLevel
        }
    }
    
    // ----------------------------------------------------
    // 2. 【典籍名篇】模式：与勋章馆「典籍名篇」一致（诗经 / 尚书 … 每本一枚）
    // ----------------------------------------------------
    private var classicsModeCards: some View {
        sectionCards(for: repository.badges.filter { $0.category == .classics })
    }
    
    // ----------------------------------------------------
    // 3. 【处世修养】模式：与勋章馆「处世修养」一致（从 badges.json 取）
    // ----------------------------------------------------

    private var practicalModeCards: some View {
        sectionCards(for: repository.badges.filter { $0.category == .practical })
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
