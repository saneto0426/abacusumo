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
    @State private var isSkipConfirmation = false
    @State private var totalPlayTime: TimeInterval = 0
    @State private var lastProblemStartTime: Date?
    @State private var solveIntervals: [TimeInterval] = []
    @State private var ghostSolvedCount = 0

    // ★ 赤い点滅用のアニメーション変数ですわ
    @State private var redFlashAlpha = 0.0

    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    var body: some View {
        ZStack {
            // --- 1. 背景レイヤー ---
            Image(ghostToBeat == nil ? "o_play_screen" : "n_play_screen")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .clipped()
                .ignoresSafeArea()

            // --- 2. UIレイヤー ---
            GeometryReader { geo in
                VStack(spacing: 0) {
                    // --- 上部：中断ボタン ---
                    HStack {
                        Button(action: { onBack() }) {
                            HStack(spacing: 5) {
                                Image(systemName: "house.fill")
                                Text("QUIT")
                            }
                            .font(.system(size: isPad ? 20 : 14, weight: .bold))
                            .padding(isPad ? 12 : 8)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(12)
                            .foregroundColor(.black)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, isPad ? 40 : 20)
                    .padding(.top, geo.safeAreaInsets.top + 5)

                    Spacer(minLength: 5)

                    // --- 中部：掲示板（高さを固定） ---
                    ZStack {
                        Image("board")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: isPad ? 450 : 260)
                        
                        Text(currentDisplayText)
                            .font(.system(size: isPad ? 90 : 50, weight: .bold, design: .monospaced))
                            .foregroundColor(.black)
                            .minimumScaleFactor(0.5)
                    }
                    .frame(height: geo.size.height * 0.22)

                    Spacer(minLength: 5)

                    // --- 下部：土俵と力士（点滅演出を追加！） ---
                    ZStack(alignment: .bottom) {
                        Image(ghostToBeat == nil ? "o_stage" : "n_stage")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geo.size.width * (isPad ? 0.75 : 0.9))

                        Group {
                            if currentIndex == 0 || isGameOver {
                                HStack(spacing: isPad ? 150 : 80) {
                                    Image("sumo_rikishi_harite2").resizable().aspectRatio(contentMode: .fit).frame(width: isPad ? 200 : 100)
                                    Image("sumo_rikishi_harite2").resizable().aspectRatio(contentMode: .fit).frame(width: isPad ? 200 : 100).scaleEffect(x: -1)
                                }
                            } else {
                                Image("sumo_torikumi")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: isPad ? 240 : 120)
                                    .offset(x: (geo.size.width * 0.6) * CGFloat(gameState - 0.5))
                            }
                        }
                        .offset(y: isPad ? -40 : -20)
                        // ★ ここで負けそうな時に画像を赤く染めますわ！
                        .colorMultiply(gameState < 0.2 && !isGameOver ? Color(red: 1.0, green: 1.0 - redFlashAlpha, blue: 1.0 - redFlashAlpha) : .white)
                    }
                    .frame(height: geo.size.height * 0.25)

                    Spacer(minLength: 10)

                    // --- 最下部：テンキー ---
                    VStack(spacing: isPad ? 15 : 8) {
                        Text(userInput.isEmpty ? (isSkipConfirmation ? "SKIP?" : " ") : userInput)
                            .font(.system(size: isPad ? 50 : 30, weight: .bold))
                            .foregroundColor(isSkipConfirmation ? .red : .black)
                            .frame(width: isPad ? 400 : 200, height: isPad ? 80 : 45)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)

                        GameNumberPad(userInput: $userInput, isSkipConfirmation: $isSkipConfirmation, actionLabel: mainLabel, actionColor: mainColor, onAction: handleMainAction, isPad: isPad)
                    }
                    .padding(.bottom, geo.safeAreaInsets.bottom + (isPad ? 30 : 10))
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            setupFirst()
            // ★ 点滅用のアニメーションを永続的に動かしておきますわ
            withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                redFlashAlpha = 0.7 // 0.0(白) から 0.7(かなり赤) まで変化します
            }
        }
        .onReceive(timer) { _ in update() }
    }

    // --- ロジック ---
    func handleMainAction() {
        if isGameOver { resetGame() }
        else if isAnswering {
            if userInput.isEmpty {
                if isSkipConfirmation { isSkipConfirmation = false; startNext() }
                else { isSkipConfirmation = true }
            } else { isSkipConfirmation = false; check() }
        } else { nextStep() }
    }

    func setupFirst() { currentQuiz = generator.makeQuiz(config: config); currentDisplayText = "READY"; wonGame = false; isGameOver = false }
    func resetGame() { gameState = 0.5; totalPlayTime = 0; solveIntervals = []; ghostSolvedCount = 0; isSkipConfirmation = false; setupFirst() }
    func startNext() { currentQuiz = generator.makeQuiz(config: config); currentIndex = 0; userInput = ""; isAnswering = false; isSkipConfirmation = false; nextStep() }
    func nextStep() { if currentIndex < currentQuiz.numbers.count { currentDisplayText = "\(currentQuiz.numbers[currentIndex])"; currentIndex += 1; if currentIndex == 1 { lastProblemStartTime = Date() } } else { currentDisplayText = "?"; isAnswering = true } }
    func check() { let interval = Date().timeIntervalSince(lastProblemStartTime ?? Date()); solveIntervals.append(interval); if Int(userInput) == currentQuiz.answer { gameState = min(1.0, gameState + 0.12) }; if gameState >= 1.0 { finish(won: true) } else { startNext() } }
    func update() { guard !isGameOver && currentIndex > 0 else { return }; totalPlayTime += 0.05; gameState -= 0.001; if let ghost = ghostToBeat { let ghostTargetTime = ghost.solveIntervals.prefix(ghostSolvedCount + 1).reduce(0, +); if totalPlayTime >= ghostTargetTime { gameState -= 0.08; ghostSolvedCount += 1 } }; if gameState <= 0 { finish(won: false) } }
    
    func finish(won: Bool) {
        isGameOver = true; wonGame = won; currentDisplayText = won ? "WIN!" : "LOSE..."
        if won {
            let newRecord = GhostRecord(mode: config.mode, configLabel: config.label, solveIntervals: solveIntervals, date: Date())
            ghostManager.saveRecord(newRecord)
            showResultDialog = true
        }
    }
    
    var generator: ProblemGeneratable { switch config.mode { case .addition: return SimpleProblemGenerator(); case .multiplication: return MultiProblemGenerator(); case .division: return DivProblemGenerator() } }
    var mainLabel: String { isGameOver ? "RETRY" : (isAnswering && userInput.isEmpty && isSkipConfirmation ? "SKIP?" : (isAnswering ? "OK" : (currentIndex == 0 ? "START" : "NEXT"))) }
    var mainColor: Color { isGameOver ? .blue : (isAnswering && userInput.isEmpty && isSkipConfirmation ? .red : (isAnswering ? .orange : .green)) }
}

// テンキーの設計図
struct GameNumberPad: View {
    @Binding var userInput: String
    @Binding var isSkipConfirmation: Bool
    let actionLabel: String
    let actionColor: Color
    var onAction: () -> Void
    let isPad: Bool
    let rows = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"]]
    
    var body: some View {
        let keyW: CGFloat = isPad ? 120 : 65
        let keyH: CGFloat = isPad ? 85 : 45
        VStack(spacing: isPad ? 10 : 5) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: isPad ? 10 : 5) {
                    ForEach(row, id: \.self) { label in
                        Button(action: { userInput += label; isSkipConfirmation = false }) {
                            ZStack { Image("key").resizable().frame(width: keyW, height: keyH); Text(label).font(.system(size: isPad ? 28 : 18, weight: .bold)).foregroundColor(.black) }
                        }
                    }
                }
            }
            HStack(spacing: isPad ? 10 : 5) {
                Button(action: { userInput = ""; isSkipConfirmation = false }) { ZStack { Image("key").resizable().frame(width: keyW, height: keyH); Text("C").font(.system(size: isPad ? 28 : 18, weight: .bold)).foregroundColor(.red) } }
                Button(action: { userInput += "0"; isSkipConfirmation = false }) { ZStack { Image("key").resizable().frame(width: keyW, height: keyH); Text("0").font(.system(size: isPad ? 28 : 18, weight: .bold)).foregroundColor(.black) } }
                Button(action: onAction) { ZStack { Image("key").resizable().frame(width: keyW, height: keyH); Text(actionLabel).font(.system(size: isPad ? 18 : 11, weight: .bold)).foregroundColor(actionColor) } }
            }
        }
    }
}
