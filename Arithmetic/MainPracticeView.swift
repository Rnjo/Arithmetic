import SwiftUI
import AVFoundation

struct UserDefaultsKeys {
    static let highestLevel = "highestLevel"
    static let totalQuestionsAnswered = "totalQuestionsAnswered"
    static let correctAnswers = "correctAnswers"
    static let sessionQuestionsAnswered = "sessionQuestionsAnswered"
    static let sessionCorrectAnswers = "sessioncorrectAnswers"
    
}

struct DashboardView: View {
    

    @Binding var sessionQuestionsAnswered: Int
    @Binding var sessionCorrectAnswers: Int
    @Binding var totalQuestionsAnswered: Int
    @Binding var correctAnswers: Int
    @Binding var userLevel: Int
    @Binding var highestLevel: Int // Highest level reached

    var sessionAccuracy: Double {
        sessionQuestionsAnswered > 0 ? (Double(sessionCorrectAnswers) / Double(sessionQuestionsAnswered)) * 100 : 0
    }
    
    var accuracy: Double {
        totalQuestionsAnswered > 0 ? (Double(correctAnswers) / Double(totalQuestionsAnswered)) * 100 : 0
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack {
                Text("Dashboard")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 10)

                Text("Track your progress and performance here!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top)

            Divider()

            // Current and Highest Level
            VStack(spacing: 10) {
                Text("📈 Your Current Level")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(userLevel)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)

                Text("🏆 Highest Level Achieved")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(highestLevel)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )

            Divider()

            // Performance Summary
            VStack(spacing: 10) {
                Text("📊 Session Summary")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack {
                    VStack(alignment: .leading) {
                        Text("Total Questions Answered:")
                            .font(.subheadline)
                        Text("\(sessionQuestionsAnswered)")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    Spacer()

                    VStack(alignment: .leading) {
                        Text("Correct Answers:")
                            .font(.subheadline)
                        Text("\(sessionCorrectAnswers)")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }

                HStack {
                    Text("Current session accuracy:")
                        .font(.subheadline)
                    Spacer()
                    Text("\(String(format: "%.2f", sessionAccuracy))%")
                        .font(.title2)
                        .foregroundColor(sessionAccuracy >= 80 ? .green : .red)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            
            
            
            Divider()
            VStack(spacing: 10) {
                Text("📈 Performance Summary")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack {
                    VStack(alignment: .leading) {
                        Text("Total Questions Answered:")
                            .font(.subheadline)
                        Text("\(totalQuestionsAnswered)")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    Spacer()

                    VStack(alignment: .leading) {
                        Text("Correct Answers:")
                            .font(.subheadline)
                        Text("\(correctAnswers)")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }

                HStack {
                    Text("Overall accuracy:")
                        .font(.subheadline)
                    Spacer()
                    Text("\(String(format: "%.2f", accuracy))%")
                        .font(.title2)
                        .foregroundColor(accuracy >= 80 ? .green : .red)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitle("Dashboard", displayMode: .inline)
        
    }
    
}



struct LeaderboardView: View {
    var body: some View {
        VStack {
            Text("Leaderboard")
                .font(.largeTitle)
                .bold()
            Spacer()
            Text("This is the Leaderboard page.")
                .font(.title2)
                .padding()
            Spacer()
        }
        .navigationBarTitle("Leaderboard", displayMode: .inline)
    }
}

struct CompetitionView: View {
    var body: some View {
        VStack {
            Text("Competition")
                .font(.largeTitle)
                .bold()
            Spacer()
            Text("This is the Competitions page.")
                .font(.title2)
                .padding()
            Spacer()
        }
        .navigationBarTitle("Competition", displayMode: .inline)
    }
}

struct MainPracticeView: View {
    @EnvironmentObject var appState: AppState
    @Binding var userLevel: Int // User's current level
    @State private var consecutiveWrongAnswers = 0 // Track consecutive wrong answers
    @State private var currentQuestion = ""
    
    @State public var correctAnswers = 0
    @State public var totalQuestionsAnswered = 0
    @State public var highestLevel: Int = 0
    
    @State public var sessionQuestionsAnswered = 0
    @State public var sessionCorrectAnswers = 0
    
    @State private var correctAnswer: Double = 0
    @State private var userAnswer = ""
    @State private var message = ""
    @State private var score = 0
    @State private var timeRemaining = 4 // Default to 4 seconds
    @State private var showLevelUp = false
    @State private var showLevelDown = false
    @State private var showSettings = false // State for showing settings view
    @State private var correctSoundPlayer: AVAudioPlayer?
    @State private var errorSoundPlayer: AVAudioPlayer?
    @State private var levelSoundPlayer: AVAudioPlayer?
    @State private var leveldownSoundPlayer: AVAudioPlayer?
    
    
    @State private var timer: Timer? = nil // Add a timer property to manage it
    
    @State private var currentTab: Int = 0 // Tracking current tab for swipe navigation
    
    var body: some View {
        ZStack {
            VStack {
                NavigationView {
                    TabView(selection: $currentTab) {
                        VStack {
                            Text("Welcome to Practice Mode!")
                                .font(.headline)
                                .padding(.bottom, 20)
                            
                            Text("Level \(userLevel)")
                                .font(.largeTitle)
                                .bold()
                                .padding(.bottom, 35)
                            
                            Text("What is \(currentQuestion)?")
                                .font(.title)
                                .padding()
                            
                            TextField("Enter your answer", text: $userAnswer)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                                .onChange(of: userAnswer) { newValue in
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
                            
                            if showLevelDown {
                                Text("Level Down 🤦")
                                    .font(.largeTitle)
                                    .foregroundColor(.red)
                                    .transition(.scale)
                            }
                            
                            Text("Time remaining: \(timeRemaining) seconds")
                                .font(.headline)
                                .padding()
                        }
                        .contentShape(Rectangle()) // Makes the whole view tappable
                        .onTapGesture {
                            hideKeyboard() // Dismiss the keyboard when tapping outside
                        }
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Practice")
                        }
                        .tag(0)
                        
                        DashboardView(
                            sessionQuestionsAnswered: $sessionQuestionsAnswered,
                            sessionCorrectAnswers: $sessionCorrectAnswers,
                            totalQuestionsAnswered: $totalQuestionsAnswered,
                            correctAnswers: $correctAnswers,
                            userLevel: $userLevel,
                            highestLevel: $highestLevel
                            
                        )
                        .tabItem {
                            Image(systemName: "star.fill")
                            Text("Dashboard")
                        }
                        .tag(1)
                        
                        
                        
                        LeaderboardView()
                            .tabItem {
                                Image(systemName: "list.dash")
                                Text("Leaderboard")
                            }
                            .tag(2)
                        CompetitionView()
                            .tabItem {
                                Image(systemName: "flag.fill")
                                Text("Competition")
                            }
                            .tag(3)
                    }
                    .navigationBarItems(trailing: Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gear")
                            .font(.title2)
                    })
                    .onAppear {
                        //if 
                        loadPersistentData()
                        configureAudioSession()
                        loadSounds()
                        generateQuestion()
                        startTimer()
                    }
                    .onDisappear {
                        savePersistentData()
                        timer?.invalidate()
                    }
                    .sheet(isPresented: $showSettings) {
                        SettingsView(userLevel: $userLevel)
                            .environmentObject(appState)
                    }
                }
            }
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // All existing functions below remain unchanged
    
    
    func generateQuestion() {
        timer?.invalidate()
        userAnswer = ""
        message = ""
        
        let result = generateGlobalQuestion(level: userLevel)
        currentQuestion = result.question
        correctAnswer = result.answer
        
        startTimer()
    }
    
    func loadPersistentData() {
            // Load persistent data from UserDefaults
           
            highestLevel = UserDefaults.standard.integer(forKey: UserDefaultsKeys.highestLevel)
            totalQuestionsAnswered = UserDefaults.standard.integer(forKey: UserDefaultsKeys.totalQuestionsAnswered)
            correctAnswers = UserDefaults.standard.integer(forKey: UserDefaultsKeys.correctAnswers)
        }

        func savePersistentData() {
            // Save persistent data to UserDefaults
      
            UserDefaults.standard.set(highestLevel, forKey: UserDefaultsKeys.highestLevel)
            UserDefaults.standard.set(totalQuestionsAnswered, forKey: UserDefaultsKeys.totalQuestionsAnswered)
            UserDefaults.standard.set(correctAnswers, forKey: UserDefaultsKeys.correctAnswers)
        }
    
    func loadSounds() {
        if let correctSoundURL = Bundle.main.url(forResource: "correct_sound", withExtension: "mp3") {
            correctSoundPlayer = try? AVAudioPlayer(contentsOf: correctSoundURL)
        }
        if let errorSoundURL = Bundle.main.url(forResource: "error_sound", withExtension: "mp3") {
            errorSoundPlayer = try? AVAudioPlayer(contentsOf: errorSoundURL)
        }
        if let levelSoundURL = Bundle.main.url(forResource: "levelup_sound", withExtension: "mp3") {
            levelSoundPlayer = try? AVAudioPlayer(contentsOf: levelSoundURL)
        }
        if let leveldownSoundURL = Bundle.main.url(forResource: "leveldown_sound", withExtension: "mp3") {
            leveldownSoundPlayer = try? AVAudioPlayer(contentsOf: leveldownSoundURL)
        }
    }
    
    func playLevelDownSound() {
        leveldownSoundPlayer?.play()
    }
    
    func playSuccessSound() {
        correctSoundPlayer?.play()
        
    }
    
    func playLevelSound() {
        levelSoundPlayer?.play()
    }
    
    func playErrorSound() {
        errorSoundPlayer?.play()
    }
    
    func checkAnswer() {
        sessionQuestionsAnswered+=1
        totalQuestionsAnswered += 1 // Increment the total questions answered
        
        if let userAnswer = Double(userAnswer), abs(userAnswer - correctAnswer) < 0.001 {
            sessionCorrectAnswers+=1
            correctAnswers += 1 // Increment correct answers on a correct response
            score += 1
            consecutiveWrongAnswers = 0 // Reset consecutive wrong answers on a correct answer
            if score % 5 == 0 {
                incrementLevel()
            }
            playSuccessSound()
        } else {
            message = "Incorrect, try again."
            score = 0
            consecutiveWrongAnswers += 1 // Increment consecutive wrong answers
            
            // Check if the user got 5 wrong in a row
            if consecutiveWrongAnswers >= 5 {
                decrementLevel() // Call the decrementLevel function after 5 wrong answers
                consecutiveWrongAnswers = 0 // Reset after level decrement
            }
            playErrorSound()
        }
        
        generateQuestion()
    }
    
    
    
    func incrementLevel() {
        playLevelSound()
        
        userLevel += 1
        if userLevel > highestLevel {
            highestLevel = userLevel
        }
        
        withAnimation {
            showLevelUp = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showLevelUp = false
        }
    }
    
    func decrementLevel() {
        playLevelDownSound()
        
        userLevel -= 1
        withAnimation {
            showLevelDown = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showLevelDown = false
        }
    }
    
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    func startTimer() {
        timer?.invalidate()
        
        // Calculate timeRemaining dynamically based on level
        if userLevel <= 10 {
            timeRemaining = 9
        } else {
            timeRemaining = max(2, 9 - ((userLevel - 1) / 10))
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                generateQuestion()
            }
        }
    }
}


