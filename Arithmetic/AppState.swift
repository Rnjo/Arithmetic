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
            UserDefaults.standard.set(userLevel, forKey: UserDefaultsKeys.userLevel)
        }
    }
    @Published var currentView: AppView
    @Published var diagnosticCompleted: Bool {
        didSet {
            UserDefaults.standard.set(diagnosticCompleted, forKey: UserDefaultsKeys.diagnosticCompleted)
        }
    }

    // UserDefaults keys to avoid typos
    private enum UserDefaultsKeys {
        static let diagnosticCompleted = "DiagnosticCompleted"
        static let userLevel = "UserLevel"
        static let firstLaunch = "FirstLaunch"
    }

    init() {
        // Debugging logs
        print("Initializing AppState...")
        print("UserDefaults diagnosticCompleted:", UserDefaults.standard.bool(forKey: UserDefaultsKeys.diagnosticCompleted))
        print("UserDefaults userLevel:", UserDefaults.standard.integer(forKey: UserDefaultsKeys.userLevel))

        // Check if it's the first launch
        let isFirstLaunch = UserDefaults.standard.bool(forKey: UserDefaultsKeys.firstLaunch)

        // Load diagnosticCompleted from UserDefaults
        let completed = UserDefaults.standard.bool(forKey: UserDefaultsKeys.diagnosticCompleted)
        self.diagnosticCompleted = completed

        // Load userLevel from UserDefaults
        let storedLevel = UserDefaults.standard.integer(forKey: UserDefaultsKeys.userLevel)
        self.userLevel = storedLevel == 0 ? 8 : storedLevel

        // If it's not the first launch and diagnostic is completed, show practice view
        if !isFirstLaunch {
            self.currentView = completed ? .practice : .gradeSelection
        } else {
            // If first launch, show grade selection view
            self.currentView = .gradeSelection
            // Set firstLaunch flag to true after first launch
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.firstLaunch)
        }
        
        print("AppState initialized with:")
        print("diagnosticCompleted =", diagnosticCompleted)
        print("userLevel =", userLevel)
        print("currentView =", currentView)
    }


    func resetData() {
        diagnosticCompleted = false
        userLevel = 8 // Reset userLevel to default grade level
        currentView = .gradeSelection // Force transition to grade selection
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.diagnosticCompleted)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.userLevel)
        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.firstLaunch) // Reset first launch flag
    }
}
