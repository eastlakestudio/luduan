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
                if showingLaunchScreen {
                    LaunchScreenView(isPresented: $showingLaunchScreen)
                        .transition(.opacity)
                } else {
                    MainDashboardView(pendingDeepLinkLevelId: $pendingDeepLinkLevelId)
                        .environmentObject(repository)
                        .transition(.opacity)
                }
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
