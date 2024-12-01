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
                        // Use the appState instance here
                        appState.resetData()  // Call resetData() on the injected instance of AppState
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

