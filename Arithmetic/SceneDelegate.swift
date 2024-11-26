import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appState: AppState = AppState() // Your AppState object

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Save app state when entering the background (to handle force quit or app switch)
        UserDefaults.standard.set(appState.diagnosticCompleted, forKey: "DiagnosticCompleted")
        UserDefaults.standard.set(appState.userLevel, forKey: "UserLevel")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Optional: Load state when the app becomes active again (you can use this if needed)
        let completed = UserDefaults.standard.bool(forKey: "DiagnosticCompleted")
        let storedLevel = UserDefaults.standard.integer(forKey: "UserLevel")
        appState.diagnosticCompleted = completed
        appState.userLevel = storedLevel == 0 ? 8 : storedLevel
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Optional: You can trigger any additional logic if required
    }
}
