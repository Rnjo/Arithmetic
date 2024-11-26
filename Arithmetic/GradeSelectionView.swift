import SwiftUI

struct GradeSelectionView: View {
    @State private var diagnosticCompleted = false // State for diagnostic completion
    @Binding var selectedGradeLevel: Int // Binding to receive gradeLevel from parent view

    var body: some View {
        NavigationStack {
            VStack {
                // Title Text for a more welcoming UI
                

                Text("Welcome to Arithmetic!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                // Subtitle for more context
                Text("Please select your grade level to begin.")
                    .font(.title3)
                    .padding(.bottom)

                // Grade Level Picker for selection
                Picker("Grade Level", selection: $selectedGradeLevel) {
                    ForEach(1..<13) { grade in
                        Text("Grade \(grade)").tag(grade)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .padding()

                // Button to navigate to the DiagnosticTestView
                NavigationLink(destination: DiagnosticTestView(diagnosticCompleted: $diagnosticCompleted, gradeLevel: selectedGradeLevel)) {
                    Text("Start Diagnostic Test")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.top)
                }

                // Show if the diagnostic is completed
                if diagnosticCompleted {
                    Text("Diagnostic test completed!")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding(.top)
                }
            }
            .padding()
            .navigationTitle("Grade Selection")
        }
    }
}
