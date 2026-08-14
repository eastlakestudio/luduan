import SwiftUI

public struct ChenghuangLevelMapView: View {
    @EnvironmentObject private var repository: GameDataRepository
    
    /// 选中的主题分类
    @State private var selectedTheme: CultureTheme = .shihan
    /// 选中的关卡，触发弹出 PuzzleGameView
    @State private var activeLevel: LevelModel? = nil
    
    public init(selectedTheme: CultureTheme = .shihan) {
        _selectedTheme = State(initialValue: selectedTheme)
    }
    
    private var themeLevels: [LevelModel] {
        repository.themeWords(for: selectedTheme).map {
            Classic10000LevelsEngine.levelFromWord($0)
        }
    }
    
    private var currentActiveLevel: LevelModel? {
        repository.nextUncompletedLevel(for: selectedTheme)
    }
    
    public var body: some View {
        PaperCardView(borderColor: Color.bambooGreen.opacity(0.8)) {
            VStack(spacing: 16) {
                // 1. 主题画卷页签 (史汉典故 / 诗经风雅 / 唐诗宋词)
                themeSegmentPicker
                
                // 2. 主题进度与关卡信息
                themeHeaderInfo
                
                Divider()
                
                // 3. 卷轴古风路线图 (乘黄伴学神兽站位节点)
                levelNodesScrollPath
            }
        }
        .onAppear {
            selectedTheme = repository.userProgress.lastActiveTheme
        }
        .sheet(item: $activeLevel) { level in
            PuzzleGameView(level: level)
                .environmentObject(repository)
        }
    }
    
    // MARK: - Subviews
    
    private var themeSegmentPicker: some View {
        HStack(spacing: 6) {
            ForEach(CultureTheme.allCases) { theme in
                let isSelected = selectedTheme == theme
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTheme = theme
                        repository.setActiveTheme(theme)
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: theme.iconName)
                            .font(.caption)
                        Text(theme.rawValue)
                            .font(.system(.footnote, design: .serif))
                            .bold()
                    }
                    .foregroundColor(isSelected ? .white : .xuanBlack)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(isSelected ? Color.bambooGreen : Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private var themeHeaderInfo: some View {
        let completedCount = themeLevels.filter { repository.isLevelCompleted($0.id) }.count
        let totalCount = themeLevels.count
        
        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(selectedTheme.subtitle)
                    .font(.system(.caption, design: .serif))
                    .foregroundColor(.gray)
                HStack(spacing: 6) {
                    Text(selectedTheme.rawValue)
                        .font(.system(.title3, design: .serif))
                        .bold()
                        .foregroundColor(.xuanBlack)
                    Text("地图画卷")
                        .font(.system(.caption, design: .serif))
                        .foregroundColor(.bambooGreen)
                }
            }
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("关卡破解进度")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text("\(completedCount) / \(totalCount)")
                    .font(.system(.headline, design: .serif))
                    .bold()
                    .foregroundColor(.cinnabarRed)
            }
        }
    }
    
    private var levelNodesScrollPath: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(Array(themeLevels.enumerated()), id: \.element.id) { index, level in
                    let isCompleted = repository.isLevelCompleted(level.id)
                    let isChenghuangHere = (currentActiveLevel?.id == level.id)
                    let levelIndex = index + 1
                    
                    levelMapNodeCard(
                        level: level,
                        index: levelIndex,
                        isCompleted: isCompleted,
                        isChenghuangHere: isChenghuangHere
                    )
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 10)
        }
    }
    
    private func levelMapNodeCard(
        level: LevelModel,
        index: Int,
        isCompleted: Bool,
        isChenghuangHere: Bool
    ) -> some View {
        Button(action: {
            activeLevel = level
        }) {
            VStack(spacing: 8) {
                // 乘黄脚印立绘与指引气泡
                if isChenghuangHere {
                    VStack(spacing: 2) {
                        Text("乘黄等待挑战")
                            .font(.system(size: 10, weight: .bold, design: .serif))
                            .foregroundColor(.cinnabarRed)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.cloudGold.opacity(0.3))
                            .cornerRadius(10)
                        
                        // 乘黄 Q 版图像/头像
                        chenghuangAvatarImage
                            .frame(width: 44, height: 44)
                            .shadow(color: Color.cloudGold.opacity(0.5), radius: 6, x: 0, y: 3)
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    Spacer().frame(height: 52)
                }
                
                // 关卡节点图标
                ZStack {
                    Circle()
                        .fill(
                            isChenghuangHere ? Color.cloudGold.opacity(0.3) :
                                (isCompleted ? Color.bambooGreen.opacity(0.15) : Color.gray.opacity(0.1))
                        )
                        .frame(width: 56, height: 56)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    isChenghuangHere ? Color.cloudGold :
                                        (isCompleted ? Color.bambooGreen : Color.borderAncient),
                                    lineWidth: isChenghuangHere ? 3 : 1.5
                                )
                        )
                    
                    if isCompleted {
                        VStack(spacing: 1) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.bambooGreen)
                                .font(.headline)
                            Text("第\(index)关")
                                .font(.system(size: 9, weight: .bold, design: .serif))
                                .foregroundColor(.bambooGreen)
                        }
                    } else if isChenghuangHere {
                        VStack(spacing: 1) {
                            Image(systemName: "play.fill")
                                .foregroundColor(.cinnabarRed)
                                .font(.headline)
                            Text("第\(index)关")
                                .font(.system(size: 9, weight: .bold, design: .serif))
                                .foregroundColor(.cinnabarRed)
                        }
                    } else {
                        VStack(spacing: 1) {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                            Text("第\(index)关")
                                .font(.system(size: 9, weight: .bold, design: .serif))
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // 关卡名称（隐藏成语或提示已破解成语）
                Text(isCompleted ? level.title : "第 \(index) 关")
                    .font(.system(.footnote, design: .serif))
                    .bold()
                    .foregroundColor(isCompleted ? .xuanBlack : (isChenghuangHere ? .cinnabarRed : .gray))
            }
            .frame(width: 90)
        }
    }
    
    private var chenghuangAvatarImage: some View {
        Group {
            if let image = loadResourceImage(named: "chenghuang_mascot_mini") {
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
            } else {
                Image(systemName: "sparkles")
                    .font(.title)
                    .foregroundColor(.cloudGold)
            }
        }
    }
    
    private func loadResourceImage(named name: String) -> Image? {
        #if canImport(UIKit)
        if let url = Bundle.module.url(forResource: name, withExtension: "jpg"),
           let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        #elseif canImport(AppKit)
        if let url = Bundle.module.url(forResource: name, withExtension: "jpg"),
           let data = try? Data(contentsOf: url),
           let nsImage = NSImage(data: data) {
            return Image(nsImage: nsImage)
        }
        #endif
        return nil
    }
}
