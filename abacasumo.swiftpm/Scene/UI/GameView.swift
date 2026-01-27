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
    let ghostToBeat: GhostRecord? // これがnilならシングルモード
    var onBack: () -> Void

    @State private var gameState: Double = 0.5
    @State private var isGameOver = false
    @State private var currentQuiz: (numbers: [Int], answer: Int) = ([], 0)
    @State private var currentIndex = 0
    @State private var currentDisplayText: String = "READY"
    @State private var userInput: String = ""
    @State private var isAnswering = false
    
    // 変数定義
    @State private var showEmptyWarning = false
    @State private var showNameInput = false
    @State private var inputName = ""
    
    @State private var totalPlayTime: TimeInterval = 0
    @State private var lastProblemStartTime: Date?
    @State private var solveIntervals: [TimeInterval] = []
    
    // ゴースト用変数
    @State private var ghostSolveTimestamps: [TimeInterval] = []
    @State private var nextGhostIndex = 0

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
                    
                    // --- テンキー (下部) ---
                    SorobanTenkey(userInput: $userInput, actionLabel: mainLabel, onAction: handleMainAction, isPad: isPad)
                        .padding(.bottom, geo.safeAreaInsets.bottom + 15)
                        .disabled(showNameInput) // 名前入力中は無効化
                }
            }

            // 名前入力画面 (ZStackの最後に配置)
            if showNameInput {
                Color.black.opacity(0.6).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("勝負あり！")
                        .font(.custom("Edo SZ", size: 40))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    Text("番付に名前を刻め")
                        .font(.body)
                        .foregroundColor(.white)
                    
                    TextField("名前を入力", text: $inputName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 200)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                    
                    Button(action: saveRecord) {
                        ZStack {
                            Image("key")
                                .resizable()
                                .frame(width: 140, height: 50)
                            Text("奉 納")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                    .disabled(inputName.isEmpty)
                    
                    Button("保存せずに戻る") {
                        onBack()
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(UIColor.systemBackground))
                        .frame(width: 300, height: 350)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15).stroke(Color.black, lineWidth: 2)
                        )
                )
            }
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
        
        // ゴーストと時間の初期化
        totalPlayTime = 0
        ghostSolveTimestamps = []
        nextGhostIndex = 0
        
        // ゴーストがいる場合のみ、解答タイミング表を作る
        if let ghost = ghostToBeat {
            var accumulatedTime: TimeInterval = 0
            for interval in ghost.solveIntervals {
                accumulatedTime += interval
                ghostSolveTimestamps.append(accumulatedTime)
            }
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
            gameState = min(1.0, gameState + 0.1) // プレイヤーが押し返す強さ
        }
        startNext()
    }

    func update() {
        guard !isGameOver && currentDisplayText != "READY" && currentIndex > 0 else { return }
        
        // 経過時間を更新
        totalPlayTime += 0.05
        
        // ★ここが分岐点です！★
        if ghostToBeat == nil {
            // ▼ シングルモード：時間経過でじわじわ減る（毒沼方式）
            // 0.0005 は好みの速さに調整してください
            gameState -= 0.0005
            
        } else {
            // ▼ ゴーストモード：相手が解いた時だけ減る（マリカ方式）
            if nextGhostIndex < ghostSolveTimestamps.count {
                if totalPlayTime >= ghostSolveTimestamps[nextGhostIndex] {
                    // ゴーストのアタック！
                    gameState -= 0.1 // プレイヤーの回復量と同じにすると公平です
                    nextGhostIndex += 1
                }
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

// MARK: - SorobanTenkey
struct SorobanTenkey: View {
    @Binding var userInput: String
    let actionLabel: String
    var onAction: () -> Void
    let isPad: Bool

    let columns = [
        ["1", "4", "7", "C"],
        ["2", "5", "8", "0"],
        ["3", "6", "9", "S"]
    ]

    var body: some View {
        HStack(spacing: isPad ? 14 : 5) {
            ForEach(0..<3) { colIndex in
                VStack(spacing: isPad ? 0 : 12) {
                    ForEach(columns[colIndex], id: \.self) { key in
                        Button(action: {
                            if key == "S" { onAction() }
                            else if key == "C" { userInput = "" }
                            else { userInput += key }
                        }) {
                            ZStack {
                                Image("key")
                                    .resizable()
                                    .frame(width: isPad ? 120 : 58, height: isPad ? 88 : 44)
                                
                                Text(key == "S" ? actionLabel : key)
                                    .font(.custom("Papyrus", size: isPad ? 44 : 26))
                                    .font(.system(size: key == "S" ? (isPad ? 18 : 10) : (isPad ? 28 : 18), weight: .black))
                                    .foregroundColor(key == "S" ? .green : (key == "C" ? .red : .black))
                            }
                            .offset(y: isPad ? 30 : 20)
                        }
                    }
                }
            }
        }
        .offset(y: isPad ? 150 : 20)
    }
}
