import SwiftUI

public struct MainDashboardView: View {
    @EnvironmentObject private var repository: GameDataRepository
    
    @State private var selectedDimension: ThemeDimension = .academic
    @State private var activeGameLevel: LevelModel? = nil
    @State private var showingBadgeGallery = false
    @AppStorage(SoundManager.soundEnabledKey) private var soundEnabled = true
    
    private static var bannerCache: Image? = nil
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.paperWhite.ignoresSafeArea()
                
                VStack(spacing: 16) {
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
            .navigationTitle("《甪端字游》")
            .inlineNavigationBarTitle()
            .toolbar {
                ToolbarItem(placement: .adaptiveLeading) {
                    Button(action: {
                        soundEnabled.toggle()
                    }) {
                        Image(systemName: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .foregroundColor(.bambooGreen)
                    }
                }
                ToolbarItem(placement: .adaptiveTrailing) {
                    Button(action: { showingBadgeGallery = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "seal.fill")
                                .foregroundColor(.cinnabarRed)
                            Text("勋章馆")
                                .font(.system(.subheadline, design: .serif))
                                .bold()
                                .foregroundColor(.cinnabarRed)
                        }
                    }
                }
            }
            #if os(iOS)
            .fullScreenCover(item: $activeGameLevel) { level in
                PuzzleGameView(level: level)
                    .environmentObject(repository)
            }
            #else
            .sheet(item: $activeGameLevel) { level in
                PuzzleGameView(level: level)
                    .environmentObject(repository)
            }
            #endif
            .sheet(isPresented: $showingBadgeGallery) {
                BadgeGalleryView()
                    .environmentObject(repository)
            }
        }
    }
    
    private var mascotBannerImage: Image {
        if let cached = Self.bannerCache { return cached }
        #if canImport(UIKit)
        if let url = Bundle.module.url(forResource: "luDuan_splash_banner", withExtension: "jpg") ??
                     Bundle.module.url(forResource: "luDuan_splash_banner", withExtension: "jpg", subdirectory: "BadgeImages"),
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
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("神兽甪端伴学护航")
                        .font(.system(.headline, design: .serif))
                        .bold()
                        .foregroundColor(.xuanBlack)
                    
                    Text("一万关典籍成语博览 · 解破 10 关小通关御赐金印")
                        .font(.system(.caption, design: .serif))
                        .foregroundColor(.gray)
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
        return VStack(spacing: 16) {
            ForEach(items) { badge in
                badgeSectionCard(badge: badge)
            }
        }
    }

    private func badgeSectionCard(badge: BadgeModel) -> some View {
        let bLevels = repository.levelsForBadge(badge)
        let progress = repository.badgeProgressInfo(badge)
        let completed = progress.completed
        let count = progress.total
        let ratio = progress.ratio
        let isFreshPlay = repository.isThemeInFreshPlay(badge.id)

        return PaperCardView(borderColor: ratio >= 1.0 ? Color.cloudGold : Color.borderAncient) {
            HStack(spacing: 16) {
                ThreeStateBadgeView(
                    sealText: badge.sealText,
                    imageName: badge.imageName,
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
            let nextLevel = isFreshPlay ? bLevels.first : (bLevels.first { !repository.isLevelCompleted($0.id) } ?? bLevels.first)
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
    // 3. 【处世修养】模式：按 7 大古汉语主题纵向排列
    // ----------------------------------------------------
    private var practicalModeCards: some View {
        VStack(spacing: 16) {
            practicalThemeCard(theme: .xiushen, subtitle: "吾日三省吾身 · 我心匪石 · 天下难事必作于易", startIndex: 0, count: 1500, sealText: "修身\n立德")
            practicalThemeCard(theme: .qijia, subtitle: "家勤则兴人勤则俭 · 桃之夭夭 · 颜氏家训", startIndex: 1500, count: 1400, sealText: "齐家\n修业")
            practicalThemeCard(theme: .jiaoyou, subtitle: "海内存知己 · 喜时之言多失信 · 爱人者人恒爱之", startIndex: 2900, count: 1400, sealText: "处世\n交友")
            practicalThemeCard(theme: .huozhi, subtitle: "奇货可居 · 日中则移月满则亏 · 周身针砭", startIndex: 4300, count: 1400, sealText: "计然\n货殖")
            practicalThemeCard(theme: .bingfa, subtitle: "知己知彼 · 破釜沉舟 · 草船借箭 · 刮骨疗毒", startIndex: 5700, count: 1500, sealText: "兵法\n韬略")
            practicalThemeCard(theme: .zhiguo, subtitle: "德胜才谓之君子 · 先天下之忧而忧 · 勿以恶小而为之", startIndex: 7200, count: 1400, sealText: "治国\n理政")
            practicalThemeCard(theme: .pingtianxia, subtitle: "大江东去浪淘尽 · 长风破浪会有时 · 会当凌绝顶", startIndex: 8600, count: 1400, sealText: "平天\n下怀")
        }
    }
    
    private func practicalThemeCard(theme: PracticalTheme, subtitle: String, startIndex: Int, count: Int, sealText: String) -> some View {
        let pLevels = repository.levelsForCategory(theme.rawValue)
        let progress = repository.practicalThemeProgressInfo(theme: theme)
        let completed = progress.completed
        let totalCount = progress.total
        let ratio = progress.ratio
        let cleanTheme = theme.rawValue.replacingOccurrences(of: "《", with: "").replacingOccurrences(of: "》", with: "")
        let isFreshPlay = repository.isThemeInFreshPlay(cleanTheme)
        
        return PaperCardView(borderColor: ratio >= 1.0 ? Color.cloudGold : Color.borderAncient) {
            HStack(spacing: 16) {
                ThreeStateBadgeView(
                    sealText: sealText,
                    imageName: nil,
                    progressRatio: ratio,
                    size: 80
                )
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(theme.rawValue)
                            .font(.system(.title3, design: .serif))
                            .bold()
                            .foregroundColor(.cinnabarRed)
                        Spacer()
                        
                        Button(action: {
                            repository.toggleFreshReplayMode(for: cleanTheme)
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
                        
                        Text("\(completed) / \(totalCount) 词")
                            .font(.system(.subheadline, design: .serif))
                            .bold()
                            .foregroundColor(.gray)
                    }
                    
                    Text(subtitle)
                        .font(.system(.footnote, design: .serif))
                        .foregroundColor(.xuanBlack)
                    
                    ProgressView(value: ratio)
                        .tint(ratio >= 1.0 ? Color.cloudGold : Color.cinnabarRed)
                }
            }
        }
        .onTapGesture {
            let nextLevel = isFreshPlay ? pLevels.first : (pLevels.first { !repository.isLevelCompleted($0.id) } ?? pLevels.first)
            activeGameLevel = nextLevel
        }
    }
}
