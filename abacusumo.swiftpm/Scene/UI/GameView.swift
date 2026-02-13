//
//  BattleView.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/20.
//
import SwiftUI

struct GameView: View {
    @ObservedObject var ghostManager: GhostManager
    let config: LevelConfig
    let ghostToBeat: GhostRecord?
    var onBack: () -> Void

    // --- 状態変数 ---
    @State private var gameState: Double = 0.5
    @State private var isGameOver = false
    @State private var currentQuiz: (numbers: [Int], answer: Int) = ([], 0)
    @State private var currentIndex = 0
    @State private var currentDisplayText: String = "READY"
    @State private var userInput: String = ""
    @State private var isAnswering = false
    @State private var showEmptyWarning = false
    @State private var showNameInput = false
    @State private var inputName = ""
    
    // 計測・制御用
    @State private var lastProblemStartTime: Date?
    @State private var solveIntervals: [TimeInterval] = []
    
    // マリカ方式用
    @State private var totalPlayTime: TimeInterval = 0
    @State private var ghostSolveTimestamps: [TimeInterval] = []
    @State private var nextGhostIndex = 0

    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    var body: some View {
        ZStack {
            // 背景
            Image(ghostToBeat == nil ? "o_play_screen" : "n_play_screen")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .clipped()
            .ignoresSafeArea()

            // ★ここ！ 新しいレイアウトを呼び出すだけ！とてもシンプル
            AbacusLayout(
                isPad: isPad,
                gameState: gameState,
                currentDisplayText: currentDisplayText,
                userInput: userInput,
                isAnswering: isAnswering,
                isGameOver: isGameOver,
                showEmptyWarning: showEmptyWarning,
                onKeyInput: handleKeyInput
            )

            // 戻るボタン
            VStack {
                HStack {
                    Button(action: onBack) {
                        Image("back")
                            .resizable().scaledToFit()
                            .frame(width: isPad ? 45 : 30)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding(.top, isPad ? 40 : 50)
            .padding(.leading, 20)
            .opacity(showNameInput ? 0 : 1)
           
            // 名前入力オーバーレイ
            if showNameInput {
                NameInputView(
                    inputName: $inputName,
                    onSave: saveRecord,
                    onCancel: { onBack() }
                )
            }
        }
        .onAppear { setupFirst() }
        .onReceive(timer) { _ in update() }
        .onChange(of: userInput) { _ in
            if !userInput.isEmpty { showEmptyWarning = false }
        }
    }
    
    // Generatorの定義
    var generator: ProblemGeneratable {
        if config.mode == .addition {
            return SimpleProblemGenerator()
        } else {
            return MultiProblemGenerator()
        }
    }

    // --- ロジック部分 (変更なし) ---
    
    func handleKeyInput(_ key: String) {
            if showNameInput { return }
           
            // Sボタン（進行ボタン）の処理
            if key == "S" {
                if isGameOver {
                    resetGame()
                } else if isAnswering {
                    if userInput.isEmpty {
                        if showEmptyWarning { startNext() } else { showEmptyWarning = true }
                    } else {
                        check()
                    }
                } else {
                    nextStep()
                }
                return // Sボタンの処理が終わったらここで抜ける
            }
            
            // ★ここに追加！
            // 回答モード（isAnswering）じゃない時は、ここで無視して終了！
            // これで問題表示中に数字を押しても反応しなくなります
            if !isAnswering { return }

            // 数字とCボタンの処理
            if key == "C" {
                userInput = ""
            } else {
                // 桁数制限（例: 8桁まで）を入れるとさらに親切です
                if userInput.count < 8 {
                    userInput += key
                }
            }
        }
    
    func setupFirst() {
        currentQuiz = generator.makeQuiz(config: config)
        currentDisplayText = "READY"
        currentIndex = 0
        isGameOver = false
        solveIntervals = []
        showNameInput = false
        inputName = ""
        showEmptyWarning = false
        lastProblemStartTime = Date()
        
        // ★マリカ方式の初期化
        totalPlayTime = 0
        ghostSolveTimestamps = []
        nextGhostIndex = 0
        
        if let ghost = ghostToBeat {
            var accumulatedTime: TimeInterval = 0
            for interval in ghost.solveIntervals {
                accumulatedTime += interval
                ghostSolveTimestamps.append(accumulatedTime)
            }
        }
    }
    
    func resetGame() { gameState = 0.5; setupFirst() }
    
    func startNext() {
        currentQuiz = generator.makeQuiz(config: config)
        currentIndex = 0; userInput = ""; isAnswering = false; showEmptyWarning = false; lastProblemStartTime = Date(); nextStep()
    }
    
    func nextStep() {
        if currentIndex < currentQuiz.numbers.count {
            currentDisplayText = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                if self.currentIndex < self.currentQuiz.numbers.count {
                    self.currentDisplayText = "\(self.currentQuiz.numbers[self.currentIndex])"
                    self.currentIndex += 1
                    if self.currentIndex == 1 { self.lastProblemStartTime = Date() }
                }
            }
        } else { isAnswering = true }
    }
    
    func check() {
        if let startTime = lastProblemStartTime { solveIntervals.append(Date().timeIntervalSince(startTime)) }
        if Int(userInput) == currentQuiz.answer { gameState = min(1.0, gameState + 0.1) }
        startNext()
    }
    
    func update() {
        guard !isGameOver && currentDisplayText != "READY" && currentIndex > 0 else { return }
        
        totalPlayTime += 0.05
        
        if ghostToBeat == nil {
            gameState -= 0.0005
        } else {
            if nextGhostIndex < ghostSolveTimestamps.count {
                if totalPlayTime >= ghostSolveTimestamps[nextGhostIndex] {
                    gameState -= 0.1
                    nextGhostIndex += 1
                }
            }
        }
        
        if gameState <= 0.0 { isGameOver = true; currentDisplayText = "LOSE" }
        else if gameState >= 1.0 { isGameOver = true; currentDisplayText = "WIN!"; showNameInput = true }
    }
    
    func saveRecord() {
        let newRecord = GhostRecord(mode: config.mode, configLabel: config.label, solveIntervals: solveIntervals, date: Date(), playerName: inputName)
        ghostManager.saveRecord(newRecord)
        onBack()
    }
}



