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
            UserDefaults.standard.set(userLevel, forKey: UserDefaultsKey.userLevel)
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
            UserDefaults.standard.set(diagnosticCompleted, forKey: UserDefaultsKey.diagnosticCompleted)
        }
    }

    // Performance summary variables (not persisted)
    @Published var totalQuestionsAnswered: Int = 0
    @Published var correctAnswers: Int = 0

    // UserDefaults keys
    private enum UserDefaultsKey {
        static let diagnosticCompleted = "DiagnosticCompleted"
        static let userLevel = "UserLevel"
        static let appLaunchedBefore = "AppLaunchedBefore"
    }

    init() {
        // Load stored values from UserDefaults
        let appLaunchedBefore = UserDefaults.standard.bool(forKey: UserDefaultsKey.appLaunchedBefore)
        let storedDiagnosticCompleted = UserDefaults.standard.bool(forKey: UserDefaultsKey.diagnosticCompleted)
        let storedUserLevel = UserDefaults.standard.integer(forKey: UserDefaultsKey.userLevel)
        
        self.diagnosticCompleted = storedDiagnosticCompleted
        self.userLevel = storedUserLevel == 0 ? 8 : storedUserLevel // Default to level 8
        
        if !appLaunchedBefore {
            // First launch setup: show grade selection and then diagnostic
            self.currentView = .gradeSelection
            UserDefaults.standard.set(true, forKey: UserDefaultsKey.appLaunchedBefore)
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
    public func resetData() {
        self.totalQuestionsAnswered = 0
        self.correctAnswers = 0
        
        print("Resetting all data...")
        // Reset UserDefaults for AppState
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.diagnosticCompleted)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.userLevel)
        // Reset UserDefaults for MainPracticeView
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.highestLevel)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.totalQuestionsAnswered)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.correctAnswers)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.sessionQuestionsAnswered)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.sessionCorrectAnswers)
        print("Data reset: currentView=\(currentView), totalQuestionsAnswered=\(totalQuestionsAnswered), correctAnswers=\(correctAnswers)")
        
        self.diagnosticCompleted = false
        self.userLevel = 8 // Reset userLevel to default grade level
        self.currentView = .gradeSelection

       
       

        // Reload state from UserDefaults to reflect the latest values
         

        


    }

}
