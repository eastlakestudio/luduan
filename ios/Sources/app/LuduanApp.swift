import SwiftUI
#if canImport(luDuanCore)
import luDuanCore
#endif

@main
struct LuduanApp: App {
    @StateObject private var repository = GameDataRepository.shared
    @State private var showingLaunchScreen = true
    @State private var pendingDeepLinkLevelId: String? = nil
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                #if DEBUG
                if let dumpBadge = ProcessInfo.processInfo.environment["LUDUAN_DUMP_BADGE"] {
                    VStack {
                        Color.clear
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if let badge = repository.badges.first(where: { $0.name == dumpBadge }) {
                                let ws = repository.badgeWords(for: badge.id)
                                print("[LUDUAN_DUMP] \(dumpBadge) 词池 \(ws.count) 条:")
                                for w in ws { print("  - \(w.phrase) | \(w.source)") }
                            } else {
                                print("[LUDUAN_DUMP] 未找到 badge: \(dumpBadge)")
                            }
                            exit(0)
                        }
                    }
                } else if let testPhrase = ProcessInfo.processInfo.environment["LUDUAN_TEST_PHRASE"] {
                    let word = repository.allWords.first { $0.phrase == testPhrase } ?? repository.allWords.first
                    if let word {
                        PuzzleGameView(level: Classic10000LevelsEngine.levelFromWord(word, categoryName: "验证关卡"))
                            .environmentObject(repository)
                    }
                } else if showingLaunchScreen {
                    LaunchScreenView(isPresented: $showingLaunchScreen)
                        .transition(.opacity)
                } else {
                    MainDashboardView(pendingDeepLinkLevelId: $pendingDeepLinkLevelId)
                        .environmentObject(repository)
                        .transition(.opacity)
                }
                #else
                if showingLaunchScreen {
                    LaunchScreenView(isPresented: $showingLaunchScreen)
                        .transition(.opacity)
                } else {
                    MainDashboardView(pendingDeepLinkLevelId: $pendingDeepLinkLevelId)
                        .environmentObject(repository)
                        .transition(.opacity)
                }
                #endif
            }
            .animation(.easeInOut(duration: 0.4), value: showingLaunchScreen)
            .onOpenURL { url in
                // 处理 widget 深度链接：luduan://level/{levelId}
                guard url.scheme == "luduan",
                      url.host == "level",
                      !url.lastPathComponent.isEmpty else { return }
                let levelId = url.lastPathComponent
                if showingLaunchScreen {
                    showingLaunchScreen = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    pendingDeepLinkLevelId = levelId
                }
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    repository.syncFromAppGroup()
                }
            }
        }
    }
}
