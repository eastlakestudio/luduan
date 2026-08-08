import SwiftUI
import luDuanCore

@main
struct LuduanApp: App {
    @StateObject private var repository = GameDataRepository.shared
    @State private var showingLaunchScreen = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showingLaunchScreen {
                    LaunchScreenView(isPresented: $showingLaunchScreen)
                        .transition(.opacity)
                } else {
                    MainDashboardView()
                        .environmentObject(repository)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: showingLaunchScreen)
        }
    }
}
