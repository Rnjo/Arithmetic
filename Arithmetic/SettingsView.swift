//
//  SettingsView.swift
//  Arithmetic
//
//  Created by Mihir Kotamraju on 11/25/24.
//


import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Binding var userLevel: Int
    @State var darkmode: Bool = false
    @State private var showResetConfirmation = false // State for reset confirmation alert

    var body: some View {
        NavigationView {
            
            List {
                Section(header: Text("Settings")) {
                    /*Button("Dark Mode"){
                        darkmode = true
                    }
                    .foregroundColor(.black)*/
                    Button("Reset Data") {
                        showResetConfirmation = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .listStyle(InsetGroupedListStyle())
            .alert(isPresented: $showResetConfirmation) {
                Alert(
                    title: Text("Reset Data"),
                    message: Text("Are you sure you want to reset all progress? This will take you back to the diagnostic test."),
                    primaryButton: .destructive(Text("Reset")) {
                        resetData()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    /// Resets all user progress, including the diagnostic test
    private func resetData() {
        appState.diagnosticCompleted = false
        userLevel = 1 // Reset the level to the starting value
        appState.currentView = .gradeSelection // Redirect to the diagnostic view
    }
}
