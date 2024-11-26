import SwiftUI

struct DiagnosticTestView: View {
    @EnvironmentObject var appState: AppState
    @Binding var diagnosticCompleted: Bool
    let gradeLevel: Int

    @State private var currentQuestionIndex = 0
    @State private var questions: [(question: String, answer: Double)] = []
    @State private var userAnswers: [String] = [] // Ensure this is initialized properly during setup
    @State private var score = 0
    @State private var totalTimeTaken: Double = 0.0
    @State private var showResults = false
    @State private var timer: Timer?
    @State private var timeRemaining = 8

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

                Text("Your starting level is \(appState.userLevel).")
                    .font(.headline)
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
                Text("Question \(currentQuestionIndex + 1) of \(totalQuestions)")
                    .font(.headline)

                if !questions.isEmpty {
                    Text(questions[currentQuestionIndex].question)
                        .font(.title)
                        .padding()
                }

                TextField("Enter your answer", text: Binding(
                    get: {
                        // Ensure the currentQuestionIndex is valid
                        if currentQuestionIndex < userAnswers.count {
                            return userAnswers[currentQuestionIndex]
                        } else {
                            return ""
                        }
                    },
                    set: { newValue in
                        // Safely set the user answer for the current question
                        if currentQuestionIndex < userAnswers.count {
                            userAnswers[currentQuestionIndex] = newValue
                        }
                    }
                ))
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onChange(of: userAnswers) { _ in
                    // Replace period with minus sign
                    if currentQuestionIndex < userAnswers.count {
                        if userAnswers[currentQuestionIndex].contains(".") {
                            userAnswers[currentQuestionIndex] = userAnswers[currentQuestionIndex].replacingOccurrences(of: ".", with: "-")
                        }
                    }
                }

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

    func setupQuestions() {
        questions = (1...totalQuestions).map { _ in generateGlobalQuestion(level: gradeLevel) }
        userAnswers = Array(repeating: "", count: totalQuestions) // Properly initialize userAnswers
        startTimer()
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                moveToNextQuestion()
            }
        }
    }

    func moveToNextQuestion() {
        if currentQuestionIndex + 1 < totalQuestions {
            currentQuestionIndex += 1
            totalTimeTaken += Double(8 - timeRemaining)
            timeRemaining = 8
            startTimer()
        } else {
            showResults = true
            computeLevel()
            timer?.invalidate()
        }
    }

    func checkAnswer() {
        guard currentQuestionIndex < questions.count else { return }

        if let userAnswer = Double(userAnswers[currentQuestionIndex]),
           abs(userAnswer - questions[currentQuestionIndex].answer) < 0.001 {
            score += 1
        }

        moveToNextQuestion()
    }

    func computeLevel() {
        let accuracy = Double(score) / Double(totalQuestions)
        let averageTime = totalTimeTaken / Double(totalQuestions)

        if accuracy >= 0.8 && averageTime < 5.0 {
            appState.userLevel = gradeLevel + 2
        } else if accuracy >= 0.5 {
            appState.userLevel = gradeLevel + 1
        } else {
            appState.userLevel = gradeLevel
        }
    }
}
