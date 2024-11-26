import SwiftUI

enum AppView {
    case gradeSelection
    case diagnostic
    case practice
    case settings
}

class AppState: ObservableObject {
    @Published var userLevel: Int {
        didSet {
            print("Setting userLevel to \(userLevel)")
            UserDefaults.standard.set(userLevel, forKey: UserDefaultsKeys.userLevel)
            UserDefaults.standard.synchronize() // Ensure sync immediately
        }
    }

    @Published var currentView: AppView
    @Published var diagnosticCompleted: Bool {
        didSet {
            print("Setting diagnosticCompleted to \(diagnosticCompleted)")
            UserDefaults.standard.set(diagnosticCompleted, forKey: UserDefaultsKeys.diagnosticCompleted)
            UserDefaults.standard.synchronize() // Ensure sync immediately
        }
    }

    private enum UserDefaultsKeys {
        static let diagnosticCompleted = "DiagnosticCompleted"
        static let userLevel = "UserLevel"
        static let appLaunchedBefore = "AppLaunchedBefore"
    }

    init() {
        // Load values from UserDefaults
        let appLaunchedBefore = UserDefaults.standard.bool(forKey: UserDefaultsKeys.appLaunchedBefore)
        let storedDiagnosticCompleted = UserDefaults.standard.bool(forKey: UserDefaultsKeys.diagnosticCompleted)
        let storedUserLevel = UserDefaults.standard.integer(forKey: UserDefaultsKeys.userLevel)

        // Set local properties
        self.diagnosticCompleted = storedDiagnosticCompleted
        self.userLevel = storedUserLevel == 0 ? 8 : storedUserLevel // Default to level 8 if not set

        // Debug prints
        

        // Determine the initial view based on the diagnostic state
        if !appLaunchedBefore {
            self.currentView = .gradeSelection
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.appLaunchedBefore)
        } else {
            if storedDiagnosticCompleted {
                self.currentView = .practice // Go to practice if diagnostic is completed
            } else {
                self.currentView = .diagnostic // Go to diagnostic if not completed
            }
        }

        // Debug print for initial view
        print("Initial currentView set to: \(self.currentView)")
    }

    // Reset all data and go back to grade selection
    func resetData() {
        print("Resetting data...")
        self.diagnosticCompleted = false
        self.userLevel = 8 // Reset userLevel to default grade level
        self.currentView = .gradeSelection

        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.diagnosticCompleted)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.userLevel)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.appLaunchedBefore)

        print("After reset, currentView set to: \(self.currentView)")
    }
}
