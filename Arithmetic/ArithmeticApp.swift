import SwiftUI

@main
struct ArithmeticApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            switch appState.currentView {
            case .gradeSelection:
                GradeSelectionView(selectedGradeLevel: $appState.userLevel)
                    .environmentObject(appState)
            case .diagnostic:
                DiagnosticTestView(diagnosticCompleted: $appState.diagnosticCompleted, gradeLevel: appState.userLevel)
                    .environmentObject(appState)
            case .practice:
                MainPracticeView(userLevel: $appState.userLevel)
                    .environmentObject(appState)
            case .settings:
                SettingsView(userLevel: $appState.userLevel)
                    .environmentObject(appState)
            }
        }
        .onChange(of: appState.currentView) { newValue in
            // Debug the view transition state
            print("Transitioning to new view: \(newValue)")
        }
    }
}
