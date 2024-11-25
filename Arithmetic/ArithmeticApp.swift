import SwiftUI

@main
struct ArithmeticApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            switch appState.currentView {
            case .gradeSelection:
                GradeSelectionView(selectedGradeLevel: $appState.userLevel) // Pass the binding to selectedGradeLevel
                    .environmentObject(appState)
            case .diagnostic:
                DiagnosticTestView(diagnosticCompleted: $appState.diagnosticCompleted, gradeLevel: appState.userLevel) // Pass dynamic gradeLevel
                    .environmentObject(appState)
            case .practice:
                MainPracticeView(userLevel: $appState.userLevel) // Pass dynamic userLevel
                    .environmentObject(appState)
            case .settings:
                SettingsView(userLevel: $appState.userLevel) // Pass dynamic userLevel for settings
                    .environmentObject(appState)
            }
        }
    }
}
