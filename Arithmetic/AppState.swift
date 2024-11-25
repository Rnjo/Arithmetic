import SwiftUI

enum AppView {
    case gradeSelection
    case diagnostic
    case practice
    case settings
}

class AppState: ObservableObject {
    @Published var userLevel: Int = 8 // The grade level or user level
    @Published var currentView: AppView
    @Published var diagnosticCompleted: Bool {
        didSet {
            UserDefaults.standard.set(diagnosticCompleted, forKey: "DiagnosticCompleted")
        }
    }

    // Initialize properties with default values
    init() {
        // Initialize diagnosticCompleted with UserDefaults or default to false
        let completed = UserDefaults.standard.bool(forKey: "DiagnosticCompleted")
        self.diagnosticCompleted = completed
        
        // Set the currentView based on diagnosticCompleted
        self.currentView = completed ? .practice : .gradeSelection
    }

    func resetData() {
        diagnosticCompleted = false
        currentView = .gradeSelection // Force transition to grade selection
        UserDefaults.standard.set(false, forKey: "DiagnosticCompleted")
    }
}
