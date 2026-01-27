//
//  BattleView.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/20.
//
import SwiftUI

// MARK: - GameView
struct GameView: View {
    @ObservedObject var ghostManager: GhostManager
    let config: LevelConfig
    let ghostToBeat: GhostRecord? // nilならシングルモード
    var onBack: () -> Void

    @State private var gameState: Double = 0.5
    @State private var isGameOver = false
    @State private var currentQuiz: (numbers: [Int], answer: Int) = ([], 0)
    @State private var currentIndex = 0
    @State private var currentDisplayText: String = "READY"
    @State private var userInput: String = ""
    @State private var isAnswering = false
    
    // UI用変数
    @State private var showEmptyWarning = false
    @State private var showNameInput = false
    @State private var inputName = ""
    
    // 計測用
    @State private var lastProblemStartTime: Date?
    @State private var solveIntervals: [TimeInterval] = []
    
    // ★変更: ゴースト制御用の変数
    @State private var ghostAverageInterval: TimeInterval = 3.0 // デフォルト値
    @State private var ghostAttackTimer: TimeInterval = 0 // 攻撃までのカウントダウン

    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    var body: some View {
        ZStack {
            // 1. 背景レイヤー
            Image(ghostToBeat == nil ? "o_play_screen" : "n_play_screen")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .clipped()
                .ignoresSafeArea()

            GeometryReader { geo in
                VStack(spacing: 0) {
                    // --- ゲームステージ (中央エリア) ---
                    ZStack {
                        // 【レイヤー4：一番奥】掲示板 (Board)
                        VStack {
                            ZStack {
                                Spacer()
                                Image("board")
                                    .resizable()
                                    .frame(width: isPad ? 400 : 220, height: isPad ? 300 : 90)
                                
                                Text(isAnswering ? (userInput.isEmpty ? "?" : userInput) : currentDisplayText)
                                    .font(.system(size: isPad ? 70 : 38, weight: .black, design: .monospaced))
                                    .foregroundColor(showEmptyWarning ? .red : .black)
                            }
                            Spacer()
                        }
                        .offset(y: isPad ? 150 : 20)
                        .frame(height: isPad ? 600 : 350)
                        .zIndex(0)

                        // 【レイヤー3：フレーム】
                        Image("frame")
                            .resizable()
                            .frame(width: geo.size.width * 0.925, height: isPad ? 480 : 200)
                            .frame(width: geo.size.width, height: isPad ? 100 : 180)
                            .offset(y: isPad ?  595:30) // 掲示板の下に来るように調整
                            .zIndex(1)

                        // 【レイヤー2：玉たち (ゲージ)】
                        HStack(spacing: isPad ? 14 : 18) {
                            let bW: CGFloat = isPad ? 120 : 30
                            let sp: CGFloat = isPad ? 14 : 18
                            let totalW = (bW * 5) + (sp * 4)

                            ForEach(0..<5) { i in
                                let rightEdge = (-totalW / 2) + (bW * CGFloat(i + 1)) + (sp * CGFloat(i))
                                let threshold = (rightEdge / geo.size.width) + 0.5
                                
                                Image("key").resizable()
                                    .frame(width: bW, height: isPad ? 88 : 22)
                                    .colorMultiply(gameState > threshold ? .white : .black)
                            }
                        }
                        .offset(y: isPad ? 430 : 35)
                        .zIndex(2)

                        // 【レイヤー1：一番手前】相撲 (Sumo)
                        Group {
                            if currentDisplayText == "READY" || isGameOver {
                                HStack(spacing: isPad ? 120 : 70) {
                                    Image("sumo_rikishi_harite2").resizable().aspectRatio(contentMode: .fit).frame(width: isPad ? 200 : 105)
                                    Image("sumo_rikishi_harite2").resizable().aspectRatio(contentMode: .fit).frame(width: isPad ? 200 : 105).scaleEffect(x: -1)
                                }
                            } else {
                                Image("sumo_torikumi").resizable().aspectRatio(contentMode: .fit).frame(width: isPad ? 220 : 120)
                                    .offset(x: geo.size.width * 1 * CGFloat(gameState - 0.5))
                            }
                        }
                        .offset(y: isPad ? 270 : -40)
                        .zIndex(3)
                    }
                    .frame(width: geo.size.width, height: isPad ? 600 : 350)
                    Spacer()
                    // --- テンキー (下部) ---
                    SorobanTenkey(userInput: $userInput, actionLabel: mainLabel, onAction: handleMainAction, isPad: isPad)
//                        .padding(.bottom, geo.safeAreaInsets.bottom + 15)
                        .disabled(showNameInput) // 名前入力中は無効化
                        .offset(y: 0) // テンキー自体のズレは0に
                        .padding(.bottom, 20) // 下に少し余裕を持たせる
                    
                    Spacer()
                   
                }
                .frame(width: geo.size.width) // 横幅はいっぱいに
                    // ★修正2: 全体をガツンと上に引き上げます！
                    // 盤面の上にある「透明な余白」を画面外に出すイメージです。
                    // 実機でまだ低い場合は、この -200 を -250 や -300 に増やしてください。
                    .offset(y: isPad ? 0 : 0)
            }

//
            
        } // ZStackここまで
        .onAppear { setupFirst() }
        .onReceive(timer) { _ in update() }
        .onChange(of: userInput) { _ in
            if !userInput.isEmpty {
                showEmptyWarning = false
            }
        }
        .overlay(alignment: .topLeading) {
            // 戻るボタン
            Button(action: onBack) {
                ZStack {
                    Image("back")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: isPad ? 45 : 18, height: isPad ? 45 : 18)
                        .foregroundColor(.white)
                }
            }
            .padding(.top, isPad ? 40 : 50)
            .padding(.leading, 20)
            .opacity(showNameInput ? 0 : 1) // 名前入力中は隠す
        }
    }

    // MARK: - Logic functions
    func handleMainAction() {
        if showNameInput { return }
        
        if isGameOver {
            resetGame()
        } else if isAnswering {
            if userInput.isEmpty {
                if showEmptyWarning {
                    startNext()
                } else {
                    showEmptyWarning = true
                }
            } else {
                check()
            }
        } else {
            nextStep()
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
        
        // ゴーストとタイマーの初期化
        ghostAttackTimer = 0
        
        // ★変更: 平均ペースを計算するロジック
        if let ghost = ghostToBeat, !ghost.solveIntervals.isEmpty {
            let totalTime = ghost.solveIntervals.reduce(0, +)
            // 合計時間 ÷ 問題数 = 1問あたりの平均秒数
            ghostAverageInterval = totalTime / Double(ghost.solveIntervals.count)
            print("Ghost Average Interval: \(ghostAverageInterval) sec")
        } else {
            // シングルモードやデータがない時の安全策（ここでは使いませんが）
            ghostAverageInterval = 999
        }
    }
    
    func resetGame() {
        gameState = 0.5
        setupFirst()
    }

    func startNext() {
        currentQuiz = generator.makeQuiz(config: config)
        currentIndex = 0
        userInput = ""
        isAnswering = false
        showEmptyWarning = false
        lastProblemStartTime = Date()
        nextStep()
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
        } else {
            isAnswering = true
        }
    }

    func check() {
        if let startTime = lastProblemStartTime {
            let interval = Date().timeIntervalSince(startTime)
            solveIntervals.append(interval)
        }
        if Int(userInput) == currentQuiz.answer {
            gameState = min(1.0, gameState + 0.1) // プレイヤーの押し返し
        }
        startNext()
    }

    func update() {
        guard !isGameOver && currentDisplayText != "READY" && currentIndex > 0 else { return }
        
        // ★ここが分岐点です！★
        if ghostToBeat == nil {
            // ▼ シングルモード：時間経過でじわじわ減る（毒沼方式）
            gameState -= 0.0005
            
        } else {
            // ▼ ゴーストモード：平均ペースで定期的に「ガツン」と押してくる
            ghostAttackTimer += 0.05
            
            if ghostAttackTimer >= ghostAverageInterval {
                // 平均時間が経過したので、ゴーストのアタック！
                // プレイヤーが勝った時と同じ距離(0.1)だけ押し返す
                gameState -= 0.1
                
                // タイマーをリセットして次の攻撃に備える
                ghostAttackTimer = 0
            }
        }

        let bW: CGFloat = isPad ? 120 : 30
        let sp: CGFloat = isPad ? 14 : 18
        let totalW = (bW * 5) + (sp * 4)
        let screenWidth = UIScreen.main.bounds.width

        let loseThreshold = ((-totalW / 2 + bW) / screenWidth) + 0.5
        let winThreshold = ((totalW / 2) / screenWidth) + 0.5

        if gameState <= loseThreshold {
            isGameOver = true
            currentDisplayText = "LOSE"
        } else if gameState >= winThreshold {
            isGameOver = true
            currentDisplayText = "WIN!"
            showNameInput = true
        }
    }
    
    var generator: ProblemGeneratable {
        config.mode == .addition ? SimpleProblemGenerator() : MultiProblemGenerator()
    }
    
    var mainLabel: String {
        isGameOver ? "RETRY" : (isAnswering ? "OK" : "ST")
    }
        
    func saveRecord() {
        let newRecord = GhostRecord(
            mode: config.mode,
            configLabel: config.label,
            solveIntervals: solveIntervals,
            date: Date(),
            playerName: inputName
        )
        ghostManager.saveRecord(newRecord)
        onBack()
    }
}



