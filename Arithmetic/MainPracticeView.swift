import SwiftUI
import AVFoundation
import Combine

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
    @Binding var userLevel: Int
    @State private var currentQuestion = ""
    @State private var correctAnswer: Double = 0
    @State private var userAnswer = ""
    @State private var message = ""
    @State private var score = 0
    @State private var timeRemaining = 4
    @State private var showLevelUp = false
    @State private var showSettings = false
    @State private var correctSoundPlayer: AVAudioPlayer?
    @State private var errorSoundPlayer: AVAudioPlayer?
    @State private var levelSoundPlayer: AVAudioPlayer?
    @State private var timer: Timer? = nil
    @State private var currentTab: Int = 0

    // Keyboard management
    @State private var keyboardHeight: CGFloat = 0
    @State private var isKeyboardVisible: Bool = false

    private var keyboardWillShowPublisher: AnyPublisher<Notification, Never> {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .eraseToAnyPublisher() // Cast to AnyPublisher
    }

    private var keyboardWillHidePublisher: AnyPublisher<Notification, Never> {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .eraseToAnyPublisher() // Cast to AnyPublisher
    }

    var body: some View {
        ZStack {
            VStack {
                NavigationView {
                    TabView(selection: $currentTab) {
                        VStack {
                            GeometryReader { geometry in
                                VStack {
                                    Text("Practice Mode")
                                        .font(.system(size: geometry.size.width * 0.07))
                                        .padding(.bottom, 10) // Reduced padding between question and level text

                                    Text("Level \(userLevel)")
                                        .font(.system(size: geometry.size.width * 0.1))
                                        .bold()
                                        .padding(.bottom, 30) // Reduced space between question and level

                                    Text("What is \(currentQuestion)?")
                                        .font(.system(size: geometry.size.width * 0.08))
                                        .padding()

                                    Spacer().frame(height: 10) // Reduced spacing between the question and answer input

                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(.systemGray6))
                                            .frame(height: 100)

                                        TextField("Enter your answer", text: $userAnswer)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal)
                                            .onTapGesture {
                                                // Optional: handle any action when the text field is tapped
                                            }
                                    }
                                    .padding()

                                    Spacer().frame(height: isKeyboardVisible ? 10 : 20) // Reduced the space for the top elements when the keyboard is up

                                    Text("Time remaining: \(timeRemaining) seconds")
                                        .font(.system(size: geometry.size.width * 0.07))
                                        .padding()

                                    Button("Submit Answer") {
                                        checkAnswer()
                                    }
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)

                                    Spacer().frame(minHeight: isKeyboardVisible ? 40 : 100) // Ensures enough space at the bottom when keyboard is visible
                                }
                                .padding(.horizontal)
                            }
                        }
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Practice")
                        }
                        .tag(0)
                        
                        // Placeholder for other views
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
                        
                        // Subscribe to keyboard visibility notifications
                        self.keyboardWillShowPublisher
                            .sink { notification in
                                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                                    self.keyboardHeight = keyboardFrame.height
                                    self.isKeyboardVisible = true
                                }
                            }
                            .store(in: &cancellables)
                        
                        self.keyboardWillHidePublisher
                            .sink { _ in
                                self.isKeyboardVisible = false
                            }
                            .store(in: &cancellables)
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
        .gesture(
            TapGesture()
                .onEnded {
                    hideKeyboard()
                }
        )
        .padding(.bottom, keyboardHeight > 80 ? 80 : keyboardHeight) // Adjust bottom padding based on keyboard height
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    // Cancelable objects for subscription
    @State private var cancellables = Set<AnyCancellable>()


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
        } else if userLevel >= 20 && userLevel <= 29 {
            timeRemaining = 8
        } else if userLevel >= 30 {
            timeRemaining = 10
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                self.message = "Time's up!"
                self.playErrorSound()
                self.generateQuestion()
            }
        }
    }
}
