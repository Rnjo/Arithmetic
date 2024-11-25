import SwiftUI
import AudioToolbox // Import the AudioToolbox framework for system sounds

struct MainPracticeView: View {
    @EnvironmentObject var appState: AppState
    @Binding var userLevel: Int // User's current level
    @State private var currentQuestion = ""
    @State private var correctAnswer: Double = 0
    @State private var userAnswer = ""
    @State private var message = ""
    @State private var score = 0
    @State private var timeRemaining = 4 // Default to 4 seconds
    @State private var showLevelUp = false
    @State private var showSettings = false // State for showing settings view
    @State private var timer: Timer? = nil // Add a timer property to manage it
    @State private var backgroundOpacity: Double = 0 // Opacity for background color
    @State private var backgroundColor: Color = .white // Background color to be updated

    var body: some View {
        NavigationView {
            ZStack {
               // // Background color with animation
                backgroundColor
                    .edgesIgnoringSafeArea(.all)
                    .opacity(backgroundOpacity)
                    .animation(.easeInOut(duration: 0.5), value: backgroundOpacity)

                VStack(spacing: 20) {
                    Text("Welcome to Practice Mode!")
                        .font(.headline)

                    Text("Level \(userLevel)")
                        .font(.largeTitle)
                        .bold()

                    Text("What is \(currentQuestion)?")
                        .font(.title)
                        .padding()

                    // TextField for entering answer
                    TextField("Enter your answer", text: $userAnswer)
                        .keyboardType(.decimalPad) // Use decimal pad, but we will handle the input manually
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .onChange(of: userAnswer) { newValue in
                            // Replace period with minus sign
                            if newValue.contains(".") {
                                userAnswer = newValue.replacingOccurrences(of: ".", with: "-")
                            }
                        }

                    Button("Submit Answer") {
                        checkAnswer()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    if showLevelUp {
                        Text("Level Up! 🎉")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                            .transition(.scale)
                    }

                    Text("Time remaining: \(timeRemaining) seconds")
                        .font(.headline)
                        .padding()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gear")
                                .font(.title2)
                        }
                    }
                }
            }
            .onAppear {
                generateQuestion()
                startTimer()
            }
            .onDisappear {
                timer?.invalidate() // Stop the timer when the view disappears
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(userLevel: $userLevel)
                    .environmentObject(appState)
            }
        }
    }

    /// Generates a new question based on the user's current level
    func generateQuestion() {
        // Invalidate any existing timer before generating the question
        timer?.invalidate()
        userAnswer = ""
        message = ""
        
        // Generate the new question
        let result = generateGlobalQuestion(level: userLevel)
        currentQuestion = result.question
        correctAnswer = result.answer
        
        startTimer() // Start the timer for the new question
    }

    /// Checks if the user's answer is correct
    func checkAnswer() {
        if let userAnswer = Double(userAnswer), abs(userAnswer - correctAnswer) < 0.001 {
            score += 1
            if score % 5 == 0 { // Level up every 5 correct answers
                incrementLevel()
            }
            flashBackground(isCorrect: true) // Flash green for correct answer
            playSuccessSound() // Play success sound
            generateQuestion() // Generate the next question
        } else {
            message = "Incorrect, try again."
            score = 0
            flashBackground(isCorrect: false) // Flash red for incorrect answer
            playErrorSound() // Play error sound
            generateQuestion()
        }
    }

    /// Flashes the background in green or red based on correctness
    func flashBackground(isCorrect: Bool) {
        if isCorrect {
            backgroundColor = .green // Bright green for correct answer
            backgroundOpacity = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                backgroundOpacity = 0.4 // Fade to light green
            }
        } else {
            backgroundColor = .red // Bright red for incorrect answer
            backgroundOpacity = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                backgroundOpacity = 0.4 // Fade to light red
            }
        }
    }

    /// Increments the user's level and shows the level-up animation
    func incrementLevel() {
        userLevel += 1 // Increment level
        withAnimation {
            showLevelUp = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showLevelUp = false
        }
    }

    /// Starts the timer for the current question
    func startTimer() {
        timer?.invalidate()  // Invalidate any existing timer
        
        // Adjust the timeRemaining based on the user's level
        if userLevel < 10 {
            timeRemaining = 4 // Start with 4 seconds for levels below 10
        } else {
            // For every 10 levels, add 1 second to the timer
            timeRemaining = 4 + ((userLevel - 1) / 10)
        }

        // Create a new timer and start it
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                // Time's up, consider it as incorrect and move to the next question
                flashBackground(isCorrect: false) // Flash red for incorrect answer
                generateQuestion() // Generate the next question when time runs out
            }
        }
    }

    /// Play the success sound for correct answers
    func playSuccessSound() {
        AudioServicesPlaySystemSound(1025) // Success sound ID
    }

    /// Play the error sound for incorrect answers
    func playErrorSound() {
        AudioServicesPlaySystemSound(1073) // Error sound ID
    }
}

