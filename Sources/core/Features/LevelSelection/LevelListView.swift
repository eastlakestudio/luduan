import SwiftUI

public struct LevelListView: View {
    public let theme: CultureTheme
    @EnvironmentObject private var repository: GameDataRepository
    
    @State private var activeLevel: LevelModel? = nil
    
    public init(theme: CultureTheme) {
        self.theme = theme
    }
    
    private var levels: [LevelModel] {
        repository.levels.filter { $0.theme == theme }
    }
    
    public var body: some View {
        ZStack {
            Color.paperWhite.ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(levels) { level in
                        levelRowCard(level: level)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle(theme.rawValue)
        .adaptiveSheetItem(item: $activeLevel) { level in
            PuzzleGameView(level: level)
                .environmentObject(repository)
        }
    }
    
    private func levelRowCard(level: LevelModel) -> some View {
        let isCompleted = repository.isLevelCompleted(level.id)
        
        return Button(action: {
            activeLevel = level
        }) {
            PaperCardView(borderColor: isCompleted ? Color.cloudGold : Color.borderAncient) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(isCompleted ? Color.cloudGold.opacity(0.2) : Color.gray.opacity(0.1))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: isCompleted ? "checkmark.circle.fill" : "lock.open.fill")
                            .foregroundColor(isCompleted ? Color.cloudGold : Color.gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(isCompleted ? level.title : repository.levelTitleName(for: level))
                            .font(.system(.headline, design: .serif))
                            .bold()
                            .foregroundColor(.xuanBlack)
                        
                        Text(isCompleted ? level.source : "根据释义解谜")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text(isCompleted ? "已破解" : "挑战")
                        .font(.system(.subheadline, design: .serif))
                        .bold()
                        .foregroundColor(isCompleted ? .bambooGreen : .cinnabarRed)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(isCompleted ? Color.bambooGreen.opacity(0.1) : Color.cinnabarRed.opacity(0.1))
                        .cornerRadius(12)
                }
            }
        }
    }
}
