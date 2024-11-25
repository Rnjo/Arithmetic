import SwiftUI

struct ContentView: View {
    let gradeLevel: Int
    @State private var num1 = 0
    @State private var num2 = 0
    @State private var operation = ""
    @State private var correctAnswer = 0.0
    @State private var userAnswer = ""
    @State private var message = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Arithmetic Practice")
                .font(.largeTitle)
                .bold()

            Text("What is \(num1) \(operation) \(num2)?")
                .font(.title)
                .padding()

            TextField("Enter your answer", text: $userAnswer)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Submit Answer") {
                checkAnswer()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Text(message)
                .font(.title2)
                .foregroundColor(message == "Correct! 🎉" ? .green : .red)
                .padding()

            Button("Next Question") {
                self.generateQuestion()
            }
            .padding()
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .onAppear {
            self.generateQuestion()
        }
        .padding()
    }

    /// Instance method to generate a new question based on the selected grade level
    func generateQuestion() {
        let result = generateGlobalQuestion(level: gradeLevel) // Call the global function explicitly
        let components = result.question.split(separator: " ")
        num1 = Int(components[0]) ?? 0
        operation = String(components[1])
        num2 = Int(components[2]) ?? 0
        correctAnswer = result.answer
        userAnswer = ""
        message = ""
    }

    /// Checks the user's answer and updates the message accordingly
    func checkAnswer() {
        if let userAnswer = Double(userAnswer), abs(userAnswer - correctAnswer) < 0.001 {
            message = "Correct! 🎉"
        } else {
            message = "Try Again! ❌"
        }
    }
}

/// Global function to generate arithmetic questions based on grade level


