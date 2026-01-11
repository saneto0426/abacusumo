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

    @State private var gameState: Double = 0.5
    @State private var isGameOver = false
    @State private var showResultDialog = false
    @State private var wonGame = false
    @State private var currentQuiz: (numbers: [Int], answer: Int) = ([], 0)
    @State private var currentIndex = 0
    @State private var currentDisplayText: String = "READY"
    @State private var userInput: String = ""
    @State private var isAnswering = false
    @State private var isSkipConfirmation = false // ★スキップ確認用
    @State private var totalPlayTime: TimeInterval = 0
    @State private var lastProblemStartTime: Date?
    @State private var solveIntervals: [TimeInterval] = []
    @State private var ghostSolvedCount = 0

    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    var body: some View {
        ZStack {
            GeometryReader { geo in
                VStack(spacing: 0) {
                    // --- 上部：中断ボタン ---
                    HStack {
                        Button(action: { onBack() }) {
                            HStack(spacing: 5) {
                                Image(systemName: "house.fill")
                                Text("QUIT")
                            }
                            .font(.system(size: isPad ? 22 : 14, weight: .bold))
                            .padding(isPad ? 15 : 8)
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(15)
                            .foregroundColor(.black)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, isPad ? 40 : 20)
                    .padding(.top, geo.safeAreaInsets.top + 10)

                    // --- 中部：掲示板 ---
                    ZStack {
                        Image("board")
                            .resizable()
                            .frame(width: isPad ? 500 : 280, height: isPad ? 250 : 140)
                        Text(currentDisplayText)
                            .font(.system(size: isPad ? 100 : 55, weight: .bold, design: .monospaced))
                            .foregroundColor(.black)
                    }
                    .padding(.top, isPad ? 40 : 10)

                    Spacer()

                    // --- 下部：土俵と力士 ---
                    ZStack(alignment: .bottom) {
                        Image("o_stage")
                            .resizable()
                            .frame(width: geo.size.width * (isPad ? 0.8 : 0.95), height: isPad ? 140 : 70)

                        if currentIndex == 0 || isGameOver {
                            HStack(spacing: isPad ? 200 : 100) {
                                Image("sumo_rikishi_harite2").resizable().frame(width: isPad ? 220 : 110, height: isPad ? 220 : 110)
                                Image("sumo_rikishi_harite2").resizable().frame(width: isPad ? 220 : 110, height: isPad ? 220 : 110).scaleEffect(x: -1)
                            }
                            .offset(y: isPad ? -50 : -25)
                        } else {
                            Image("sumo_torikumi")
                                .resizable()
                                .frame(width: isPad ? 260 : 130, height: isPad ? 260 : 130)
                                .offset(x: geo.size.width * CGFloat(gameState - 0.5), y: isPad ? -55 : -30)
                        }
                    }

                    Spacer()

                    // --- 最下部：テンキー ---
                    VStack(spacing: isPad ? 30 : 15) {
                        Text(userInput.isEmpty ? (isSkipConfirmation ? "SKIP?" : " ") : userInput)
                            .font(.system(size: isPad ? 60 : 35, weight: .bold))
                            .foregroundColor(isSkipConfirmation ? .red : .black)
                            .frame(width: isPad ? 450 : 220, height: isPad ? 100 : 55)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(15)

                        // テンキーに isSkipConfirmation を渡せるように改造しましたわ
                        GameNumberPad(userInput: $userInput, isSkipConfirmation: $isSkipConfirmation, actionLabel: mainLabel, actionColor: mainColor, onAction: handleMainAction, isPad: isPad)
                    }
                    .padding(.bottom, geo.safeAreaInsets.bottom + (isPad ? 50 : 20))
                }
            }
        }
        .background(
            Image(ghostToBeat == nil ? "o_play_screen" : "t_play_screen")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .ignoresSafeArea()
        )
        .ignoresSafeArea()
        .onAppear { setupFirst() }
        .onReceive(timer) { _ in update() }
    }

    // --- ロジック ---
    func handleMainAction() {
        if isGameOver {
            resetGame()
        } else if isAnswering {
            if userInput.isEmpty {
                if isSkipConfirmation {
                    // 2回目の押し：スキップ確定
                    isSkipConfirmation = false
                    startNext()
                } else {
                    // 1回目の押し：確認状態へ
                    isSkipConfirmation = true
                }
            } else {
                isSkipConfirmation = false
                check()
            }
        } else {
            nextStep()
        }
    }

    func setupFirst() { currentQuiz = generator.makeQuiz(config: config); currentDisplayText = "READY"; wonGame = false; isGameOver = false }
    func resetGame() { gameState = 0.5; totalPlayTime = 0; solveIntervals = []; ghostSolvedCount = 0; isSkipConfirmation = false; setupFirst() }
    func startNext() { currentQuiz = generator.makeQuiz(config: config); currentIndex = 0; userInput = ""; isAnswering = false; isSkipConfirmation = false; nextStep() }
    func nextStep() { if currentIndex < currentQuiz.numbers.count { currentDisplayText = "\(currentQuiz.numbers[currentIndex])"; currentIndex += 1; if currentIndex == 1 { lastProblemStartTime = Date() } } else { currentDisplayText = "?"; isAnswering = true } }
    func check() { let interval = Date().timeIntervalSince(lastProblemStartTime ?? Date()); solveIntervals.append(interval); if Int(userInput) == currentQuiz.answer { gameState = min(1.0, gameState + 0.12) }; if gameState >= 1.0 { finish(won: true) } else { startNext() } }
    func update() { guard !isGameOver && currentIndex > 0 else { return }; totalPlayTime += 0.05; gameState -= 0.001; if let ghost = ghostToBeat { let ghostTargetTime = ghost.solveIntervals.prefix(ghostSolvedCount + 1).reduce(0, +); if totalPlayTime >= ghostTargetTime { gameState -= 0.08; ghostSolvedCount += 1 } }; if gameState <= 0 { finish(won: false) } }
    func finish(won: Bool) {
        isGameOver = true
        wonGame = won
        currentDisplayText = won ? "WIN!" : "LOSE..."
        
        if won {
            // 1. GhostRecordの定義（solveIntervals -> date）に合わせて作成しますわ
            let newRecord = GhostRecord(
                mode: config.mode,
                // LevelConfigに便利な .label があるので、これを使うのがスマートですわ！
                configLabel: config.label,
                solveIntervals: solveIntervals, // ここが先ですわ
                date: Date()                    // ここが後ですわ
            )
            
            // 2. 元のコードにある「saveRecord」メソッドを呼び出しますわ
            ghostManager.saveRecord(newRecord)
            
            showResultDialog = true
        }
    }
    
    var generator: ProblemGeneratable { switch config.mode { case .addition: return SimpleProblemGenerator(); case .multiplication: return MultiProblemGenerator(); case .division: return DivProblemGenerator() } }
    
    var mainLabel: String {
        if isGameOver { return "RETRY" }
        if isAnswering && userInput.isEmpty && isSkipConfirmation { return "SKIP?" }
        return isAnswering ? "OK" : (currentIndex == 0 ? "START" : "NEXT")
    }
    
    var mainColor: Color {
        if isGameOver { return .blue }
        if isAnswering && userInput.isEmpty && isSkipConfirmation { return .red }
        return isAnswering ? .orange : .green
    }
}

// テンキーの設計図（スキップ解除対応版）
struct GameNumberPad: View {
    @Binding var userInput: String
    @Binding var isSkipConfirmation: Bool // ★追加
    let actionLabel: String
    let actionColor: Color
    var onAction: () -> Void
    let isPad: Bool
    let rows = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"]]
    
    var body: some View {
        let keyW: CGFloat = isPad ? 140 : 70
        let keyH: CGFloat = isPad ? 100 : 50
        VStack(spacing: isPad ? 12 : 6) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: isPad ? 12 : 6) {
                    ForEach(row, id: \.self) { label in
                        Button(action: {
                            userInput += label
                            isSkipConfirmation = false // 入力したらスキップ確認解除
                        }) {
                            ZStack { Image("key").resizable().frame(width: keyW, height: keyH); Text(label).font(.system(size: isPad ? 32 : 18, weight: .bold)).foregroundColor(.black) }
                        }
                    }
                }
            }
            HStack(spacing: isPad ? 12 : 6) {
                Button(action: { userInput = ""; isSkipConfirmation = false }) { ZStack { Image("key").resizable().frame(width: keyW, height: keyH); Text("C").font(.system(size: isPad ? 32 : 18, weight: .bold)).foregroundColor(.red) } }
                Button(action: { userInput += "0"; isSkipConfirmation = false }) { ZStack { Image("key").resizable().frame(width: keyW, height: keyH); Text("0").font(.system(size: isPad ? 32 : 18, weight: .bold)).foregroundColor(.black) } }
                Button(action: onAction) { ZStack { Image("key").resizable().frame(width: keyW, height: keyH); Text(actionLabel).font(.system(size: isPad ? 20 : 12, weight: .bold)).foregroundColor(actionColor) } }
            }
        }
    }
}
