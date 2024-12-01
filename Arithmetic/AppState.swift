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
        }
    }

    @Published var currentView: AppView {
        didSet {
            print("Navigating to \(currentView)")
        }
    }
    
    @Published var diagnosticCompleted: Bool {
        didSet {
            print("Setting diagnosticCompleted to \(diagnosticCompleted)")
            UserDefaults.standard.set(diagnosticCompleted, forKey: UserDefaultsKeys.diagnosticCompleted)
        }
    }

    // Performance summary variables (not persisted)
    @Published var totalQuestionsAnswered: Int = 0
    @Published var correctAnswers: Int = 0

    // UserDefaults keys
    private enum UserDefaultsKeys {
        static let diagnosticCompleted = "DiagnosticCompleted"
        static let userLevel = "UserLevel"
        static let appLaunchedBefore = "AppLaunchedBefore"
    }

    init() {
        // Load stored values from UserDefaults
        let appLaunchedBefore = UserDefaults.standard.bool(forKey: UserDefaultsKeys.appLaunchedBefore)
        let storedDiagnosticCompleted = UserDefaults.standard.bool(forKey: UserDefaultsKeys.diagnosticCompleted)
        let storedUserLevel = UserDefaults.standard.integer(forKey: UserDefaultsKeys.userLevel)
        
        self.diagnosticCompleted = storedDiagnosticCompleted
        self.userLevel = storedUserLevel == 0 ? 8 : storedUserLevel // Default to level 8
        
        if !appLaunchedBefore {
            // First launch setup: show grade selection and then diagnostic
            self.currentView = .gradeSelection
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.appLaunchedBefore)
        } else {
            // If diagnostic is not completed, show diagnostic, otherwise go to mainpractice
            self.currentView = storedDiagnosticCompleted ? .diagnostic : .practice
        }

        // Debug logs
        print("App initialized: diagnosticCompleted=\(diagnosticCompleted), userLevel=\(userLevel), currentView=\(currentView)")
    }

    // Method to mark diagnostic as completed and switch to MainPracticeView
    func completeDiagnostic() {
        print("Completing diagnostic...")
        self.diagnosticCompleted = true
        self.currentView = .practice
    }

    // Method to reset all data
    func resetData() {
        print("Resetting all data...")
        self.diagnosticCompleted = false
        self.userLevel = 8 // Reset userLevel to default grade level
        self.currentView = .gradeSelection

        // Reset performance summary
        self.totalQuestionsAnswered = 0
        self.correctAnswers = 0

        // Reset UserDefaults
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.diagnosticCompleted)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.userLevel)

        print("Data reset: currentView=\(currentView), totalQuestionsAnswered=\(totalQuestionsAnswered), correctAnswers=\(correctAnswers)")
    }
}
