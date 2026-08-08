import SwiftUI

public struct PetEvolutionView: View {
    @EnvironmentObject private var repository: GameDataRepository
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    private var pet: PetModel {
        PetModel(completedLevelCount: repository.userProgress.learnedPhrases.count)
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.paperWhite.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 顶部当前状态与进化标志
                        currentStageBanner
                        
                        // 进化历程列表 (3 阶段)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("甪端神兽进化历程")
                                .font(.system(.headline, design: .serif))
                                .bold()
                                .foregroundColor(.xuanBlack)
                            
                            ForEach(PetEvolutionStage.allCases, id: \.rawValue) { stage in
                                stageCard(for: stage)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 20)
                    .ipadAdaptiveContainer(maxWidth: 760)
                }
            }
            .navigationTitle("神兽甪端进化")
            .inlineNavigationBarTitle()
            .toolbar {
                ToolbarItem(placement: .adaptiveTrailing) {
                    Button("关闭") { dismiss() }
                        .foregroundColor(.cinnabarRed)
                }
            }
        }
    }
    
    private var currentStageBanner: some View {
        PaperCardView(borderColor: Color.cloudGold) {
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.cloudGold.opacity(0.2))
                        .frame(width: 90, height: 90)
                    
                    Image(systemName: pet.currentStage.iconSymbol)
                        .font(.system(size: 48))
                        .foregroundColor(.cloudGold)
                }
                
                Text(pet.currentStage.rawValue)
                    .font(.system(.title2, design: .serif))
                    .bold()
                    .foregroundColor(.xuanBlack)
                
                Text("当前破解关卡数：\(pet.completedLevelCount)")
                    .font(.system(.subheadline, design: .serif))
                    .bold()
                    .foregroundColor(.cinnabarRed)
                
                Text("“\(pet.randomQuote)”")
                    .font(.system(.footnote, design: .serif))
                    .italic()
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
    }
    
    private func stageCard(for stage: PetEvolutionStage) -> some View {
        let isUnlocked = pet.currentStage >= stage
        
        return PaperCardView(borderColor: isUnlocked ? Color.cloudGold : Color.borderAncient) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isUnlocked ? Color.cloudGold.opacity(0.2) : Color.gray.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: stage.iconSymbol)
                        .font(.title2)
                        .foregroundColor(isUnlocked ? .cloudGold : .gray)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(stage.rawValue)
                            .font(.system(.headline, design: .serif))
                            .bold()
                            .foregroundColor(isUnlocked ? .xuanBlack : .gray)
                        Spacer()
                        
                        Text("需破解 \(stage.requiredCompletedLevels) 关")
                            .font(.caption)
                            .bold()
                            .foregroundColor(isUnlocked ? .bambooGreen : .gray)
                    }
                    
                    Text(stage.description)
                        .font(.system(.footnote, design: .serif))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }
            }
        }
    }
}
