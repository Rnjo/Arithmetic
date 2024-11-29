import SwiftUI
import AVFoundation

struct DashboardView: View {
    var body: some View {
        VStack {
            Text("Dashboard")
                .font(.largeTitle)
                .bold()
            Spacer()
            Text("This is the Dashboard page.")
                .font(.title2)
                .padding()
            Spacer()
        }
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
    @State private var currentQuestion = ""
    @State private var correctAnswer: Double = 0
    @State private var userAnswer = ""
    @State private var message = ""
    @State private var score = 0
    @State private var timeRemaining = 4 // Default to 4 seconds
    @State private var showLevelUp = false
    @State private var showSettings = false // State for showing settings view
    @State private var correctSoundPlayer: AVAudioPlayer?
    @State private var errorSoundPlayer: AVAudioPlayer?
    @State private var levelSoundPlayer: AVAudioPlayer?

    @State private var timer: Timer? = nil // Add a timer property to manage it

    @State private var currentTab: Int = 0 // Tracking current tab for swipe navigation

    var body: some View {
        ZStack {
            VStack {
                // Main content goes here
                NavigationView {
                    TabView(selection: $currentTab) {
                        VStack {
                            Text("Welcome to Practice Mode!")
                                .font(.headline)
                                .padding(.bottom, 20) // Added space between the text

                            Text("Level \(userLevel)")
                                .font(.largeTitle)
                                .bold()
                                .padding(.bottom, 40) // Additional space between level text and the next component
                            
                            Text("What is \(currentQuestion)?")
                                .font(.title)
                                .padding()
                            
                            TextField("Enter your answer", text: $userAnswer)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                                .onChange(of: userAnswer) { newValue in
                                    // Handle input for decimal places
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
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Practice")
                        }
                        .tag(0)
                        
                        DashboardView()
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
                        configureAudioSession()
                        loadSounds()
                        generateQuestion()
                        startTimer()
                    }
                    .onDisappear {
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
    
    func generateQuestion() {
        timer?.invalidate()
        userAnswer = ""
        message = ""
        
        let result = generateGlobalQuestion(level: userLevel)
        currentQuestion = result.question
        correctAnswer = result.answer
        
        startTimer()
    }
    
    func loadSounds() {
        if let correctSoundURL = Bundle.main.url(forResource: "correct_sound", withExtension: "mp3") {
            correctSoundPlayer = try? AVAudioPlayer(contentsOf: correctSoundURL)
        }
        if let errorSoundURL = Bundle.main.url(forResource: "error_sound", withExtension: "mp3") {
            errorSoundPlayer = try? AVAudioPlayer(contentsOf: errorSoundURL)
        }
        if let levelSoundURL = Bundle.main.url(forResource: "level-sound", withExtension: "mp3") {
            levelSoundPlayer = try? AVAudioPlayer(contentsOf: levelSoundURL)
        }
    }
    
    func playSuccessSound() {
        correctSoundPlayer?.play()
        
    }
    
    func playLevelSound() {
        levelSoundPlayer?.play()
        correctSoundPlayer?.play()
    }
    
    func playErrorSound() {
        errorSoundPlayer?.play()
    }
    
    func checkAnswer() {
        if let userAnswer = Double(userAnswer), abs(userAnswer - correctAnswer) < 0.001 {
            score += 1
            if score % 5 == 0 {
                incrementLevel()
            }
            playSuccessSound()
            generateQuestion()
        } else {
            message = "Incorrect, try again."
            score = 0
            playErrorSound()
            generateQuestion()
        }
    }
    
    func incrementLevel() {
        playLevelSound()
        
        userLevel += 1
        withAnimation {
            showLevelUp = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showLevelUp = false
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
        
        if userLevel >= 1 && userLevel <= 4 {
            timeRemaining = 4
        } else if userLevel >= 5 && userLevel <= 9 {
            timeRemaining = 5
        } else if userLevel >= 10 && userLevel <= 14 {
            timeRemaining = 6
        } else if userLevel >= 15 && userLevel <= 19 {
            timeRemaining = 7
        } else if userLevel >= 20 && userLevel <= 24 {
            timeRemaining = 8
        } else {
            timeRemaining = 9 + ((userLevel - 25) / 5)
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
