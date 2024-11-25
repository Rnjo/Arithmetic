

import SwiftUI

struct DiagnosticTestView: View {
    @EnvironmentObject var appState: AppState
    @Binding var diagnosticCompleted: Bool
    let gradeLevel: Int

    @State private var currentQuestionIndex = 0
    @State private var questions: [(question: String, answer: Double)] = []
    @State private var userAnswers: [String] = []
    @State private var score = 0
    @State private var showResults = false
    @State private var timer: Timer?
    @State private var timeRemaining = 8  // 8-second timer for each question
    @State private var timerRunning = false

    private let totalQuestions = 5

    var body: some View {
            VStack(spacing: 20) {
                if showResults {
                    Text("Diagnostic Test Results")
                        .font(.largeTitle)
                        .bold()

                    Text("You scored \(score) out of \(totalQuestions).")
                        .font(.title)
                        .padding()

                    Button("Complete Test") {
                        diagnosticCompleted = true
                        appState.currentView = .practice

                    }
                    
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                } else {
                // Question View
                Text("Question \(currentQuestionIndex + 1) of \(totalQuestions)")
                    .font(.headline)

                if !questions.isEmpty {
                    Text(questions[currentQuestionIndex].question)
                        .font(.title)
                        .padding()
                }

                TextField("Enter your answer", text: Binding(
                    get: {
                        currentQuestionIndex < userAnswers.count ? userAnswers[currentQuestionIndex] : ""
                    },
                    set: { newValue in
                        if currentQuestionIndex < userAnswers.count {
                            userAnswers[currentQuestionIndex] = newValue
                        } else {
                            userAnswers.append(newValue)
                        }
                    }
                ))
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

                Text("Time Remaining: \(timeRemaining) seconds")
                    .font(.headline)
                    .padding()

                Button("Submit Answer") {
                    checkAnswer()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .onAppear {
            setupQuestions()
        }
        .onChange(of: timeRemaining) { newTime in
            if newTime == 0 {
                moveToNextQuestion()
            }
        }
    }

    /// Sets up the questions for the diagnostic test
    func setupQuestions() {
        questions = (1...totalQuestions).map { _ in generateGlobalQuestion(level: gradeLevel) }
        userAnswers = Array(repeating: "", count: totalQuestions)
        timeRemaining = 8  // Reset the timer to 8 seconds
        startTimer()
    }

    /// Starts the timer for the current question
     public func startTimer() {
        timerRunning = true
        timer?.invalidate()  // Invalidate any existing timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
    }

    /// Moves to the next question or shows results if all questions are answered
    func moveToNextQuestion() {
        if currentQuestionIndex + 1 < totalQuestions {
            currentQuestionIndex += 1
            timeRemaining = 8  // Reset timer for next question
            startTimer()
        } else {
            showResults = true
            timer?.invalidate()  // Stop the timer when the test is complete
        }
    }

    /// Checks the user's answer and moves to the next question or shows results
    func checkAnswer() {
        guard currentQuestionIndex < questions.count else { return }

        if let userAnswer = Double(userAnswers[currentQuestionIndex]),
           abs(userAnswer - questions[currentQuestionIndex].answer) < 0.001 {
            score += 1
        }

        moveToNextQuestion()
    }
}
 
