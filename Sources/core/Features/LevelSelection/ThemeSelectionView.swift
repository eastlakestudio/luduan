import SwiftUI

public struct ThemeSelectionView: View {
    @EnvironmentObject private var repository: GameDataRepository
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var selectedTheme: CultureTheme? = nil
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.paperWhite.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("请选择文化主题主线")
                            .font(.system(.subheadline, design: .serif))
                            .foregroundColor(.xuanBlack.opacity(0.6))
                            .padding(.top, 10)
                        
                        let columns = AdaptiveLayoutHelper.gridColumns(
                            for: horizontalSizeClass,
                            compactColumns: 1,
                            regularColumns: 2,
                            spacing: 16
                        )
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(CultureTheme.allCases) { theme in
                                themeCard(for: theme)
                            }
                        }
                    }
                    .padding(20)
                    .ipadAdaptiveContainer(maxWidth: 840)
                }
            }
            .navigationTitle("三大文化主题关卡")
            .inlineNavigationBarTitle()
            .toolbar {
                ToolbarItem(placement: .adaptiveTrailing) {
                    Button("关闭") { dismiss() }
                        .foregroundColor(.cinnabarRed)
                }
            }
            .navigationDestination(item: $selectedTheme) { theme in
                LevelListView(theme: theme)
                    .environmentObject(repository)
            }
        }
    }
    
    private func themeCard(for theme: CultureTheme) -> some View {
        let themeLevels = repository.levels.filter { $0.theme == theme }
        let completedCount = themeLevels.filter { repository.isLevelCompleted($0.id) }.count
        
        return Button(action: {
            repository.setActiveTheme(theme)
            selectedTheme = theme
        }) {
            PaperCardView(borderColor: Color.bambooGreen.opacity(0.6)) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.bambooGreen.opacity(0.15))
                            .frame(width: 54, height: 54)
                        
                        Image(systemName: theme.iconName)
                            .font(.title2)
                            .foregroundColor(.bambooGreen)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(theme.rawValue)
                                .font(.system(.title3, design: .serif))
                                .bold()
                                .foregroundColor(.xuanBlack)
                            Spacer()
                            
                            Text("\(completedCount)/\(themeLevels.count)")
                                .font(.system(.caption, design: .serif))
                                .bold()
                                .foregroundColor(.cinnabarRed)
                        }
                        
                        Text(theme.subtitle)
                            .font(.system(.footnote, design: .serif))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
        }
    }
}
