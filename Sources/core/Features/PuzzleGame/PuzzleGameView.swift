import SwiftUI

public struct PuzzleGameView: View {
    public let initialLevel: LevelModel
    @EnvironmentObject private var repository: GameDataRepository
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentLevel: LevelModel
    @StateObject private var engine: PuzzleEngine
    @StateObject private var speechManager = SpeechRecognitionManager.shared
    @State private var showingStoryModal = false
    @State private var showingMilestoneModal = false
    @State private var showingInspirationSheet = false
    @State private var showingSimulatorVoiceDialog = false
    @State private var simulatorVoiceInputText = ""
    @State private var shakeIncorrect = false
    
    public init(level: LevelModel) {
        self.initialLevel = level
        _currentLevel = State(initialValue: level)
        _engine = StateObject(wrappedValue: PuzzleEngine(level: level))
    }
    
    private var isMultiRowPhrase: Bool {
        engine.level.targetPhrase.count > 4
    }
    
    public var body: some View {
        ZStack {
            Color.paperWhite.ignoresSafeArea()
            
            VStack(spacing: isMultiRowPhrase ? 10 : 16) {
                // 顶栏：隐藏成语的关卡标题与灵感按钮
                headerView
                
                // 核心解谜题目：字词释义卡片
                annotationClueCard
                
                Spacer()
                
                // 已选字结果框 (支持长句/双排自适应)
                targetInputSlotsView
                
                // 神兽甪端提示气泡（若点击了字块高亮）
                if let _ = engine.highlightedTileIndex {
                    hintBubbleView
                }
                
                Spacer()
                
                // 字块矩阵 Grid
                tileMatrixGrid
                
                Spacer()
                
                // 操作按钮组
                bottomControlBar
            }
            .padding(.horizontal, 20)
            .ipadAdaptiveContainer(maxWidth: 720)
        }
        .sheet(isPresented: $showingStoryModal) {
            StoryCardModalView(
                level: currentLevel,
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
                completedCount: repository.userProgress.completedLevelIds.count,
                currentStageName: PetModel(completedLevelCount: repository.userProgress.completedLevelIds.count).currentStage.rawValue,
                onDismiss: {
                    showingMilestoneModal = false
                },
                onNextLevel: {
                    showingMilestoneModal = false
                    if let next = repository.nextLevel(after: currentLevel) {
                        loadLevel(next)
                    }
                }
            )
        }
        .sheet(isPresented: $showingInspirationSheet) {
            inspirationSourceModal
        }
        .alert("【模拟器语音拼字真实测试】", isPresented: $showingSimulatorVoiceDialog) {
            TextField("输入口述字（可测试乱说/空说/正确说）", text: $simulatorVoiceInputText)
            Button("确认口述选字") {
                let textToProcess = simulatorVoiceInputText
                speechManager.startRecording(simulatedText: textToProcess) { text in
                    engine.processVoiceInputString(text)
                }
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("Xcode 模拟器沙盒无可用于实时听写的真麦克风。您可以手动输入任意测试文本，检验【乱说话不匹配 0 字选入】与【正确说话精准选字】逻辑！")
        }
        .onChange(of: engine.isCompleted) { _, completed in
            if completed {
                // 1. 先保存关卡进度，让答题槽把全量文字完好落位并展示给玩家
                repository.completeLevel(currentLevel)
                let count = repository.userProgress.completedLevelIds.count
                
                // 2. 延迟 0.35 秒，确保玩家视觉上完全看清全量文字呈现后再播放成功音效与弹出捷报/故事卡
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    SoundManager.shared.playSuccessSound()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        if count > 0 && count % 10 == 0 {
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
            currentLevel = newLevel
            engine.resetForNewLevel(newLevel)
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        let progressInfo = repository.themeProgressInfo(for: currentLevel)
        return HStack(alignment: .center) {
            HStack(spacing: 8) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.xuanBlack)
                }
                
                Text("\(currentLevel.displayCategoryName) · 第 \(progressInfo.currentIndex)/\(progressInfo.totalCount) 词")
                    .font(.system(size: 17, weight: .bold, design: .serif))
                    .foregroundColor(.xuanBlack)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            
            Spacer(minLength: 8)
            
            HStack(spacing: 8) {
                if let prev = repository.previousLevel(before: currentLevel) {
                    Button(action: {
                        switchToPreviousLevel(prev)
                    }) {
                        Image(systemName: "backward.end.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.bambooGreen)
                            .frame(width: 34, height: 34)
                            .background(Color.bambooGreen.opacity(0.12))
                            .clipShape(Circle())
                    }
                }
                
                Button(action: {
                    skipCurrentLevel()
                }) {
                    Image(systemName: "forward.end.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.cinnabarRed)
                        .frame(width: 34, height: 34)
                        .background(Color.cinnabarRed.opacity(0.12))
                        .clipShape(Circle())
                }
                
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
        }
        .padding(.top, isMultiRowPhrase ? 42 : 54)
    }
    
    private func switchToPreviousLevel(_ prevLevel: LevelModel) {
        SoundManager.shared.playTapSound()
        currentLevel = prevLevel
        engine.resetForNewLevel(prevLevel)
    }
    
    private func skipCurrentLevel() {
        SoundManager.shared.playTapSound()
        repository.completeLevel(currentLevel)
        if let next = repository.nextLevel(after: currentLevel) {
            currentLevel = next
            engine.resetForNewLevel(next)
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
                Text(currentLevel.annotation)
                    .font(.system(size: isMultiRowPhrase ? 20 : 22, weight: .bold, design: .serif))
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
        let hintButtonTitle: String = {
            if engine.hintStage == 0 {
                return "提示 1 个正确字块"
            } else if engine.hintStage == 1 {
                return "提示 2 个正确字块"
            } else {
                return "解锁全部正确字通关"
            }
        }()
        
        return ZStack {
            Color.paperWhite.ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.cloudGold)
                        Text("甪端灵感：古文原文典故线索")
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
                            Text(currentLevel.source)
                                .font(.system(size: 20, weight: .bold, design: .serif))
                                .foregroundColor(.bambooGreen)
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("【古文原文 / 典故背景】")
                                .font(.system(.caption, design: .serif))
                                .bold()
                                .foregroundColor(.gray)
                            Text(currentLevel.story)
                                .font(.system(size: 23, weight: .bold, design: .serif))
                                .foregroundColor(.xuanBlack)
                                .lineSpacing(10)
                        }
                    }
                    .padding(18)
                    .background(Color.cloudGold.opacity(0.08))
                    .cornerRadius(12)
                }
                
                AncientButtonView(title: hintButtonTitle, iconName: "sparkles", style: .primary) {
                    _ = engine.provideHintProgressive()
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
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
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
    
    private var hintBubbleView: some View {
        let bubbleText: String = {
            if engine.hintStage == 1 {
                return "神兽甪端指引：为你锁定了 1 个正确字！"
            } else if engine.hintStage == 2 {
                return "神兽甪端指引：已为你在槽中填入 2 个字！"
            } else if engine.hintStage >= 3 {
                return "神兽甪端指引：已为你解锁通关全部字！"
            }
            return "神兽甪端指引：为你高亮了字块！"
        }()
        
        return HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .foregroundColor(.cloudGold)
            Text(bubbleText)
                .font(.system(.footnote, design: .serif))
                .foregroundColor(.xuanBlack.opacity(0.8))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
        .background(Color.cloudGold.opacity(0.2))
        .cornerRadius(16)
    }
    
    private var tileMatrixGrid: some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        let tileHeight: CGFloat = isMultiRowPhrase ? 44 : 56
        let charFontSize: CGFloat = isMultiRowPhrase ? 22 : 26
        let gridSpacing: CGFloat = isMultiRowPhrase ? 8 : 12
        
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
                            .fill(isSelected ? Color.cinnabarRed.opacity(0.1) : Color.white)
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
        HStack(spacing: 12) {
            Button(action: { engine.clearInput() }) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("重置")
                }
                .font(.system(.subheadline, design: .serif))
                .bold()
                .foregroundColor(.gray)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.12))
                .cornerRadius(12)
            }
            
            Button(action: {
                SoundManager.shared.playTapSound()
                #if targetEnvironment(simulator)
                simulatorVoiceInputText = ""
                showingSimulatorVoiceDialog = true
                #else
                speechManager.toggleRecording { text in
                    engine.processVoiceInputString(text)
                }
                #endif
            }) {
                HStack(spacing: 4) {
                    Image(systemName: speechManager.isRecording ? "mic.fill" : "mic")
                        .foregroundColor(speechManager.isRecording ? .white : .bambooGreen)
                    Text(speechManager.isRecording ? "倾听中" : "语音拼字")
                }
                .font(.system(.subheadline, design: .serif))
                .bold()
                .foregroundColor(speechManager.isRecording ? .white : .bambooGreen)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(speechManager.isRecording ? Color.cinnabarRed : Color.bambooGreen.opacity(0.15))
                .cornerRadius(12)
            }
            
            Button(action: { engine.checkAnswer() }) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark")
                    Text("完成拼字")
                }
                .font(.system(.subheadline, design: .serif))
                .bold()
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color.cinnabarRed)
                .cornerRadius(12)
            }
        }
        .padding(.bottom, 40)
    }
}
