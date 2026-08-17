import SwiftUI

public struct PuzzleGameView: View {
    public let initialLevel: LevelModel
    @EnvironmentObject private var repository: GameDataRepository
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var engine: PuzzleEngine
    @State private var showingStoryModal = false
    @State private var showingMilestoneModal = false
    @State private var showingInspirationSheet = false
    @State private var shakeIncorrect = false
    @State private var newlyUnlockedBadge: BadgeModel? = nil
    
    public init(level: LevelModel) {
        self.initialLevel = level
        _engine = StateObject(wrappedValue: PuzzleEngine(level: level))
    }
    
    private var isMultiRowPhrase: Bool {
        engine.level.targetPhrase.count > 4
    }
    
    public var body: some View {
        ZStack {
            Color.paperWhite.ignoresSafeArea()
            
            VStack(spacing: isMultiRowPhrase ? 10 : 16) {
                // 顶栏：返回、关卡标题与灵感提示按钮
                headerView
                
                // 核心解谜题目：字词释义卡片
                annotationClueCard
                
                Spacer()
                
                // 已选字结果框 (支持长句/双排自适应)
                targetInputSlotsView
                
                Spacer()
                
                // 字块矩阵 Grid
                tileMatrixGrid
                
                Spacer()
                
                // 操作按钮组：重置 与 下一个（纯图标设计）
                bottomControlBar
            }
            .padding(.horizontal, 20)
            .ipadAdaptiveContainer(maxWidth: 720)
        }
        .onAppear {
            if engine.level.id != initialLevel.id {
                engine.resetForNewLevel(initialLevel)
            }
        }
        .onChange(of: initialLevel.id) { _, _ in
            engine.resetForNewLevel(initialLevel)
        }
        .sheet(isPresented: $showingStoryModal) {
            StoryCardModalView(
                level: engine.level,
                onDismiss: { dismiss() },
                onNextLevel: { next in
                    showingStoryModal = false
                    loadLevel(next)
                }
            )
            .environmentObject(repository)
        }
        .sheet(isPresented: $showingMilestoneModal) {
            MilestoneCelebrationModalView(
                completedCount: repository.userProgress.learnedPhrases.count,
                currentStageName: PetModel(completedLevelCount: repository.userProgress.learnedPhrases.count).currentStage.rawValue,
                lastLevel: engine.level,
                onDismiss: {
                    showingMilestoneModal = false
                },
                onNextLevel: {
                    showingMilestoneModal = false
                    if let next = repository.nextLevel(after: engine.level) {
                        loadLevel(next)
                    }
                }
            )
        }
        .sheet(isPresented: $showingInspirationSheet) {
            inspirationSourceModal
        }
        .sheet(item: $newlyUnlockedBadge) { badge in
            BadgeUnlockShareView(
                badge: badge,
                fallbackLevel: engine.level,
                onDismiss: {
                    if let next = repository.nextLevel(after: engine.level) {
                        loadLevel(next)
                    } else {
                        dismiss()
                    }
                }
            )
            .environmentObject(repository)
        }
        .onChange(of: engine.isCompleted) { _, completed in
            if completed {
                // 1. 先保存关卡进度（勋章解锁优先弹勋章捷报，跳过里程碑/故事弹窗）
                let unlockedBadge = repository.completeLevel(engine.level)
                let count = repository.userProgress.learnedPhrases.count
                
                #if DEBUG
                let milestoneInterval = 5
                #else
                let milestoneInterval = 10
                #endif
                let isMilestone = count > 0 && count % milestoneInterval == 0

                DispatchQueue.main.asyncAfter(deadline: .now() + (isMilestone ? 0.4 : 0.25)) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        if let badge = unlockedBadge {
                            newlyUnlockedBadge = badge
                        } else if isMilestone {
                            showingMilestoneModal = true
                        } else {
                            showingStoryModal = true
                        }
                    }
                }
            }
        }
        .onChange(of: engine.lastCheckState) { _, state in
            if state == .incorrect {
                // 播放失败提示音效与震动
                SoundManager.shared.playFailureSound()
                withAnimation {
                    shakeIncorrect = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    shakeIncorrect = false
                }
            }
        }
    }
    
    private func loadLevel(_ newLevel: LevelModel) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            engine.resetForNewLevel(newLevel)
        }
    }
    
    // MARK: - Subviews
    
    private var displayHeaderTitle: String {
        if let badge = repository.activeBadge {
            let clean = badge.name.replacingOccurrences(of: "《", with: "").replacingOccurrences(of: "》", with: "").replacingOccurrences(of: "章", with: "").replacingOccurrences(of: "印", with: "")
            return clean
        }
        return engine.level.displayCategoryName
    }

    private var headerView: some View {
        let progressInfo = repository.themeProgressInfo(for: engine.level)
        return HStack(alignment: .center) {
            HStack(spacing: 8) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.xuanBlack)
                }
                
                Text("\(displayHeaderTitle) · 第 \(progressInfo.currentIndex)/\(progressInfo.totalCount) 词")
                    .font(.system(size: 17, weight: .bold, design: .serif))
                    .foregroundColor(.xuanBlack)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            
            Spacer(minLength: 8)
            
            Button(action: {
                showingInspirationSheet = true
            }) {
                Image(systemName: "sparkles")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.cloudGold)
                    .frame(width: 34, height: 34)
                    .background(Color.cloudGold.opacity(0.18))
                    .clipShape(Circle())
            }
        }
        .padding(.top, isMultiRowPhrase ? 42 : 54)
    }
    
    private func skipCurrentLevel() {
        SoundManager.shared.playTapSound()
        repository.completeLevel(engine.level)
        if let next = repository.nextLevel(after: engine.level) {
            loadLevel(next)
        } else {
            dismiss()
        }
    }
    
    private var annotationClueCard: some View {
        PaperCardView(borderColor: Color.cloudGold.opacity(0.6)) {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.cloudGold)
                    Text("线索")
                        .font(.system(.headline, design: .serif))
                        .bold()
                        .foregroundColor(.xuanBlack)
                    Spacer()
                }
                Divider()
                Text(engine.level.annotation)
                    .font(.system(size: isMultiRowPhrase ? 17 : 18, weight: .semibold, design: .serif))
                    .foregroundColor(.xuanBlack)
                    .lineSpacing(4)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .frame(height: isMultiRowPhrase ? 70 : 78)
            }
        }
    }
    
    private var inspirationSourceModal: some View {
        return ZStack {
            Color.paperWhite.ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.cloudGold)
                        Text("典籍溯源与灵感指引")
                            .font(.system(.title3, design: .serif))
                            .bold()
                            .foregroundColor(.xuanBlack)
                    }
                    Spacer()
                    Button("关闭") { showingInspirationSheet = false }
                        .foregroundColor(.cinnabarRed)
                }
                .padding(.top, 10)
                
                Divider()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("【典故出处】")
                                .font(.system(.caption, design: .serif))
                                .bold()
                                .foregroundColor(.gray)
                            Text(engine.level.source)
                                .font(.system(size: 20, weight: .bold, design: .serif))
                                .foregroundColor(.bambooGreen)
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("【古文原文 / 典故背景】")
                                .font(.system(.caption, design: .serif))
                                .bold()
                                .foregroundColor(.gray)
                            Text(engine.level.story)
                                .font(.system(size: 23, weight: .bold, design: .serif))
                                .foregroundColor(.xuanBlack)
                                .lineSpacing(10)
                        }
                    }
                    .padding(18)
                    .background(Color.cloudGold.opacity(0.08))
                    .cornerRadius(12)
                }
                
                AncientButtonView(title: "心领神会 · 一键通解", iconName: "sparkles", style: .primary) {
                    _ = engine.provideAllHints()
                    showingInspirationSheet = false
                }
            }
            .padding(20)
        }
    }
    
    private var targetInputSlotsView: some View {
        let targetCount = engine.level.targetPhrase.count
        let colCount = (targetCount == 8) ? 4 : min(targetCount, 5)
        let columns = Array(repeating: GridItem(.flexible(), spacing: isMultiRowPhrase ? 6 : 8), count: colCount)
        let slotHeight: CGFloat = isMultiRowPhrase ? 58 : 72
        let charFontSize: CGFloat = isMultiRowPhrase ? 26 : 32
        let pinyinFontSize: CGFloat = isMultiRowPhrase ? 15 : 18
        
        return LazyVGrid(columns: columns, spacing: isMultiRowPhrase ? 6 : 10) {
            ForEach(0..<targetCount, id: \.self) { idx in
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.borderAncient, lineWidth: 2)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.cardSurface))
                        .frame(height: slotHeight)
                    
                    if idx < engine.selectedIndices.count {
                        let tileIndex = engine.selectedIndices[idx]
                        let char = engine.tiles[tileIndex]
                        let py = PinyinHelper.pinyin(for: char)
                        
                        VStack(spacing: 2) {
                            Text(py)
                                .font(.system(size: pinyinFontSize, weight: .bold, design: .serif))
                                .foregroundColor(.cinnabarRed.opacity(0.9))
                            Text(char)
                                .font(.system(size: charFontSize, weight: .bold, design: .serif))
                                .foregroundColor(.cinnabarRed)
                        }
                        .onTapGesture {
                            SoundManager.shared.playTapSound()
                            engine.unselectTile(at: idx)
                        }
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.25))
                            .frame(width: 28, height: 3)
                            .cornerRadius(1.5)
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .offset(x: shakeIncorrect ? -8 : 0)
        .animation(.default.repeatCount(4, autoreverses: true), value: shakeIncorrect)
    }
    
    private var tileMatrixGrid: some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        let tileHeight: CGFloat = isMultiRowPhrase ? 48 : 60
        let charFontSize: CGFloat = isMultiRowPhrase ? 24 : 28
        let gridSpacing: CGFloat = isMultiRowPhrase ? 10 : 14
        
        return LazyVGrid(columns: columns, spacing: gridSpacing) {
            ForEach(0..<engine.tiles.count, id: \.self) { tileIndex in
                let isSelected = engine.selectedIndices.contains(tileIndex)
                let isHighlighted = engine.highlightedTileIndex == tileIndex
                
                Button(action: {
                    SoundManager.shared.playTapSound()
                    engine.selectTile(at: tileIndex)
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? Color.cinnabarRed.opacity(0.1) : Color.cardSurface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(
                                        isSelected ? Color.cinnabarRed :
                                            (isHighlighted ? Color.cloudGold : Color.borderAncient),
                                        lineWidth: isHighlighted ? 3 : (isSelected ? 2 : 1)
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                        
                        Text(engine.tiles[tileIndex])
                            .font(.system(size: charFontSize, weight: .bold, design: .serif))
                            .foregroundColor(isSelected ? .cinnabarRed : .xuanBlack)
                    }
                    .frame(height: tileHeight)
                }
                .disabled(isSelected)
            }
        }
    }
    
    private var bottomControlBar: some View {
        HStack {
            // 重置（左侧小巧纯图标）
            Button(action: {
                SoundManager.shared.playTapSound()
                engine.clearInput()
            }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.xuanBlack.opacity(0.6))
                    .frame(width: 44, height: 44)
                    .background(Color.xuanBlack.opacity(0.06))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .strokeBorder(Color.borderAncient.opacity(0.6), lineWidth: 1)
                    )
            }
            
            Spacer()
            
            // 下一个（右侧小巧纯图标）
            Button(action: {
                skipCurrentLevel()
            }) {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.cinnabarRed.opacity(0.85))
                    .frame(width: 44, height: 44)
                    .background(Color.cinnabarRed.opacity(0.08))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .strokeBorder(Color.cinnabarRed.opacity(0.35), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 28)
    }
}
