import SwiftUI

public struct MainDashboardView: View {
    @EnvironmentObject private var repository: GameDataRepository
    
    @State private var selectedDimension: ThemeDimension = .academic
    @State private var activeGameLevel: LevelModel? = nil
    @State private var showingBadgeGallery = false
    
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
            .navigationTitle("《甪端字游》卷轴地图")
            .inlineNavigationBarTitle()
            .toolbar {
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
    
    private var headerBannerView: some View {
        PaperCardView(borderColor: Color.cloudGold) {
            HStack(spacing: 16) {
                // 甪端神兽伴学头像
                #if canImport(UIKit)
                if let url = Bundle.module.url(forResource: "luduan_splash_banner", withExtension: "jpg") ??
                             Bundle.module.url(forResource: "luduan_splash_banner", withExtension: "jpg", subdirectory: "BadgeImages"),
                   let data = try? Data(contentsOf: url),
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.cloudGold, lineWidth: 2))
                } else {
                    Image(systemName: "crown.fill")
                        .font(.title)
                        .foregroundColor(.cloudGold)
                }
                #else
                Image(systemName: "crown.fill")
                    .font(.title)
                    .foregroundColor(.cloudGold)
                #endif
                
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
                    Text("\(repository.userProgress.completedLevelIds.count)")
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
                    .background(selectedDimension == dimension ? Color.cinnabarRed : Color.white)
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
    // 1. 【学阶功名】模式：童生 -> 秀才 -> 举人 -> 进士 -> 翰林 -> 首辅 纵向排列
    // ----------------------------------------------------
    private var academicModeCards: some View {
        VStack(spacing: 16) {
            academicRankCard(rank: .tongSheng, startIndex: 0, count: 500)
            academicRankCard(rank: .xiuCai, startIndex: 500, count: 2000)
            academicRankCard(rank: .juRen, startIndex: 2500, count: 3000)
            academicRankCard(rank: .jinShi, startIndex: 5500, count: 3000)
            academicRankCard(rank: .hanLin, startIndex: 8500, count: 1000)
            academicRankCard(rank: .shouFu, startIndex: 9500, count: 500)
        }
    }
    
    private func academicRankCard(rank: AcademicRank, startIndex: Int, count: Int) -> some View {
        let endIndex = min(10000, startIndex + count)
        let completed = (startIndex..<endIndex).filter { repository.isLevelCompleted("level_\($0 + 1)") }.count
        let ratio = Double(completed) / Double(count)
        
        return PaperCardView(borderColor: ratio >= 1.0 ? Color.cloudGold : Color.borderAncient) {
            HStack(spacing: 16) {
                // 左侧：80pt 超大 3 态勋章 (明朝风骨童生/秀才/官服卡通)
                ThreeStateBadgeView(
                    sealText: rank.badgeSealText,
                    imageName: rank.mingDynastyCartoonImageName,
                    progressRatio: ratio,
                    size: 80
                )
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(rank.rawValue)
                            .font(.system(.title3, design: .serif))
                            .bold()
                            .foregroundColor(.cinnabarRed)
                        Spacer()
                        Text("\(completed) / \(count) 关")
                            .font(.system(.subheadline, design: .serif))
                            .bold()
                            .foregroundColor(.gray)
                    }
                    
                    Text(rank.curriculumMapping)
                        .font(.system(.footnote, design: .serif))
                        .foregroundColor(.xuanBlack)
                    
                    // 进度条
                    ProgressView(value: ratio)
                        .tint(ratio >= 1.0 ? Color.cloudGold : Color.cinnabarRed)
                }
            }
        }
        .onTapGesture {
            let nextIndex = (startIndex..<endIndex).first { !repository.isLevelCompleted("level_\($0 + 1)") } ?? startIndex
            activeGameLevel = Classic10000LevelsEngine.level(at: nextIndex, categoryName: rank.rawValue)
        }
    }
    
    // ----------------------------------------------------
    // 2. 【典籍名篇】模式：严格按历史朝代先后顺序纵向排列
    // ----------------------------------------------------
    private var classicsModeCards: some View {
        VStack(spacing: 16) {
            classicsSectionCard(title: "1. 先秦典籍源头", subtitle: "《诗经》《楚辞》《尚书》《周易》《十三经》《诸子》", startIndex: 0, count: 2500, sealText: "先秦\n源头")
            classicsSectionCard(title: "2. 两汉三国史册", subtitle: "《史记》《汉书》《后汉书》《三国志》《战国策》", startIndex: 2500, count: 3000, sealText: "两汉\n三国")
            classicsSectionCard(title: "3. 魏晋南北朝", subtitle: "《颜氏家训》《世说新语》魏晋风骨", startIndex: 5500, count: 1500, sealText: "魏晋\n南北")
            classicsSectionCard(title: "4. 唐宋诗词史鉴", subtitle: "《资治通鉴》《唐诗三百首》《宋词名篇》", startIndex: 7000, count: 1800, sealText: "唐宋\n诗词")
            classicsSectionCard(title: "5. 明清名著与家书", subtitle: "《传习录》《菜根谭》《曾国藩家书》《四大名著》", startIndex: 8800, count: 1200, sealText: "明清\n名著")
        }
    }
    
    private func classicsSectionCard(title: String, subtitle: String, startIndex: Int, count: Int, sealText: String) -> some View {
        let endIndex = min(10000, startIndex + count)
        let completed = (startIndex..<endIndex).filter { repository.isLevelCompleted("level_\($0 + 1)") }.count
        let ratio = Double(completed) / Double(count)
        let cleanTitle = title.components(separatedBy: " ").last ?? title
        
        return PaperCardView(borderColor: ratio >= 1.0 ? Color.cloudGold : Color.borderAncient) {
            HStack(spacing: 16) {
                // 80pt 超大 3 态勋章
                ThreeStateBadgeView(
                    sealText: sealText,
                    imageName: nil,
                    progressRatio: ratio,
                    size: 80
                )
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(title)
                            .font(.system(.title3, design: .serif))
                            .bold()
                            .foregroundColor(.cinnabarRed)
                        Spacer()
                        Text("\(completed) / \(count) 关")
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
            let nextIndex = (startIndex..<endIndex).first { !repository.isLevelCompleted("level_\($0 + 1)") } ?? startIndex
            activeGameLevel = Classic10000LevelsEngine.level(at: nextIndex, categoryName: cleanTitle)
        }
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
        let endIndex = min(10000, startIndex + count)
        let completed = (startIndex..<endIndex).filter { repository.isLevelCompleted("level_\($0 + 1)") }.count
        let ratio = Double(completed) / Double(count)
        let cleanTheme = theme.rawValue.replacingOccurrences(of: "《", with: "").replacingOccurrences(of: "》", with: "")
        
        return PaperCardView(borderColor: ratio >= 1.0 ? Color.cloudGold : Color.borderAncient) {
            HStack(spacing: 16) {
                // 80pt 超大 3 态勋章
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
                        Text("\(completed) / \(count) 关")
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
            let nextIndex = (startIndex..<endIndex).first { !repository.isLevelCompleted("level_\($0 + 1)") } ?? startIndex
            activeGameLevel = Classic10000LevelsEngine.level(at: nextIndex, categoryName: cleanTheme)
        }
    }
}
