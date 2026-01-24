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
    let ghostToBeat: GhostRecord?
    var onBack: () -> Void

    @State private var gameState: Double = 0.5
    @State private var isGameOver = false
    @State private var currentQuiz: (numbers: [Int], answer: Int) = ([], 0)
    @State private var currentIndex = 0
    @State private var currentDisplayText: String = "READY"
    @State private var userInput: String = ""
    @State private var isAnswering = false
    @State private var totalPlayTime: TimeInterval = 0
    @State private var lastProblemStartTime: Date?
    @State private var solveIntervals: [TimeInterval] = []
    @State private var ghostSolvedCount = 0

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
                                    .frame(width: isPad ? 400 : 220, height: isPad ? 200 : 90)
                                
                                Text(isAnswering ? (userInput.isEmpty ? "?" : userInput) : currentDisplayText)
                                    .font(.system(size: isPad ? 70 : 38, weight: .black, design: .monospaced))
                                    .foregroundColor(.black)
                            }
                            Spacer() // 下にスペースを空けて上部に配置
                        }
                        .offset(y: isPad ? 150 : 20)
                        .frame(height: isPad ? 600 : 350)
                        .zIndex(0) // 最背面

                        // 【レイヤー3：フレーム】
                        Image("frame")
                            .resizable()
                            .frame(width: geo.size.width * 0.925, height: isPad ? 480 : 200)
                            .frame(width: geo.size.width, height: isPad ? 100 : 180)
                            .offset(y: isPad ?  595:30) // 掲示板の下に来るように調整
                            .zIndex(1)

                        // 【レイヤー2：玉たち (ゲージ)】
                        HStack(spacing: isPad ? 14.5 : 18) {
                            ForEach(0..<5) { i in
                                Image("key").resizable()
                                    .frame(width: isPad ? 120 : 30, height: isPad ? 88 : 22)
                                    .colorMultiply(gameState > Double(i) / 5.0 ? .white : .black)
                            }
                        }
                        .offset(y: isPad ? 430 : 35) // フレームの溝の位置に合わせる
                        .zIndex(2)

                        // 【レイヤー1：一番手前】相撲 (Sumo)
                        Group {
                            if currentIndex == 0 || isGameOver {
                                HStack(spacing: isPad ? 120 : 70) {
                                    Image("sumo_rikishi_harite2").resizable().aspectRatio(contentMode: .fit).frame(width: isPad ? 200 : 105)
                                    Image("sumo_rikishi_harite2").resizable().aspectRatio(contentMode: .fit).frame(width: isPad ? 200 : 105).scaleEffect(x: -1)
                                }
                            } else {
                                Image("sumo_torikumi").resizable().aspectRatio(contentMode: .fit).frame(width: isPad ? 220 : 120)
                                    .offset(x: geo.size.width * 0.4 * CGFloat(gameState - 0.5))
                            }
                        }
                        .offset(y: isPad ? 270 : -40) // フレームの上に乗るように少し上にずらす
                        .zIndex(3) // 最前面
                    }
                    .frame(width: geo.size.width, height: isPad ? 600 : 350)
                    // .background(Color.blue.opacity(0.1)) // デバッグ時にこれをつけると範囲が見えて便利ですわ
                    // --- テンキー (下部) ---
                    // 引数から screenWidth を削除してエラーを修正しましたわ
                    SorobanTenkey(userInput: $userInput, actionLabel: mainLabel, onAction: handleMainAction, isPad: isPad)
                        .padding(.bottom, geo.safeAreaInsets.bottom + 15)
                }
            }
        }
        .onAppear { setupFirst() }
        .onReceive(timer) { _ in update() }
    }

    // MARK: - Logic functions
    func handleMainAction() {
        if isGameOver { resetGame() }
        else if isAnswering { check() }
        else { nextStep() }
    }

    func setupFirst() {
        currentQuiz = generator.makeQuiz(config: config)
        currentDisplayText = "READY"
        isGameOver = false
    }

    func resetGame() {
        gameState = 0.5
        totalPlayTime = 0
        setupFirst()
    }

    func startNext() {
        currentQuiz = generator.makeQuiz(config: config)
        currentIndex = 0
        userInput = ""
        isAnswering = false
        nextStep()
    }

    func nextStep() {
        if currentIndex < currentQuiz.numbers.count {
            currentDisplayText = "\(currentQuiz.numbers[currentIndex])"
            currentIndex += 1
            if currentIndex == 1 { lastProblemStartTime = Date() }
        } else {
            isAnswering = true
        }
    }

    func check() {
        if Int(userInput) == currentQuiz.answer {
            gameState = min(1.0, gameState + 0.1)
        }
        startNext()
    }

    func update() {
        guard !isGameOver && currentIndex > 0 else { return }
        gameState -= 0.001
        if gameState <= 0 { isGameOver = true; currentDisplayText = "LOSE" }
        else if gameState >= 1.0 { isGameOver = true; currentDisplayText = "WIN!" }
    }

    var generator: ProblemGeneratable {
        config.mode == .addition ? SimpleProblemGenerator() : MultiProblemGenerator()
    }
    
    var mainLabel: String {
        isGameOver ? "RETRY" : (isAnswering ? "OK" : "START")
    }
}

// MARK: - SorobanTenkey
struct SorobanTenkey: View {
    @Binding var userInput: String
    let actionLabel: String
    var onAction: () -> Void
    let isPad: Bool

    // そろばんの軸（縦列）ごとのボタン
    let columns = [
        ["1", "4", "7", "C"],
        ["2", "5", "8", "0"],
        ["3", "6", "9", "START"]
    ]

    var body: some View {
        HStack(spacing: isPad ? 15 : 40) { // 列の間隔
            ForEach(0..<3) { colIndex in
                VStack(spacing: isPad ? 0 : 12) { // 玉の上下間隔
                    ForEach(columns[colIndex], id: \.self) { key in
                        Button(action: {
                            if key == "START" { onAction() }
                            else if key == "C" { userInput = "" }
                            else { userInput += key }
                        }) {
                            ZStack {
                                Image("key")
                                    .resizable()
                                    .frame(width: isPad ? 120 : 58, height: isPad ? 88 : 44) // ★デカくしましたわ！
                                
                                Text(key == "START" ? actionLabel : key)
                                    .font(.system(size: key == "START" ? (isPad ? 18 : 10) : (isPad ? 28 : 18), weight: .black))
                                    .foregroundColor(key == "START" ? .green : (key == "C" ? .red : .black))
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
