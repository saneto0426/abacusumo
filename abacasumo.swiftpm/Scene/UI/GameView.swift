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

    @State private var currentQuiz: (numbers: [Int], answer: Int) = ([], 0)
    @State private var currentIndex = 0
    @State private var currentDisplayText: String = "準備完了"
    @State private var userInput: String = ""
    @State private var isAnswering = false
    @State private var isSkipConfirmation = false

    @State private var totalPlayTime: TimeInterval = 0
    @State private var lastProblemStartTime: Date?
    @State private var solveIntervals: [TimeInterval] = []
    @State private var ghostSolvedCount = 0

    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            // 名前を 'BattleBarComponent' に修正
            BattleBarComponent(value: gameState, isGhost: ghostToBeat != nil)
                .padding(.top, 60)

            VStack(spacing: 10) {
                Text(currentDisplayText)
                    .font(.system(size: 80, weight: .bold, design: .monospaced))
                    .foregroundColor(isAnswering ? .secondary : .primary)
                
                HStack {
                    Text("入力:").font(.headline)
                    Text(userInput)
                        .font(.system(size: 45, weight: .bold, design: .monospaced))
                        .frame(minWidth: 120, minHeight: 60)
                        .background(isSkipConfirmation ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
            }
            .frame(maxHeight: .infinity)

            if showResultDialog {
                resultDialog
            } else {
                // NumberPad を呼び出す
                NumberPad(userInput: $userInput, actionLabel: mainLabel, actionColor: mainColor, onAction: handleMainAction)
                    .padding(.bottom, 40)
            }
        }
        .onAppear { setupFirst() }
        .onReceive(timer) { _ in update() }
    }

    // --- 以下ロジック (変更なし) ---
    var generator: ProblemGeneratable {
        switch config.mode {
        case .addition: return SimpleProblemGenerator()
        case .multiplication: return MultiProblemGenerator()
        case .division: return DivProblemGenerator()
        }
    }
    
    func setupFirst() {
        currentQuiz = generator.makeQuiz(config: config)
        currentDisplayText = "準備完了"
    }

    func handleMainAction() {
        if isAnswering {
            if userInput.isEmpty {
                if isSkipConfirmation { startNext() } else { isSkipConfirmation = true }
            } else { check() }
        } else { nextStep() }
    }

    func startNext() {
        currentQuiz = generator.makeQuiz(config: config)
        currentIndex = 0; userInput = ""; isAnswering = false; isSkipConfirmation = false
        nextStep()
    }

    func nextStep() {
        if currentIndex < currentQuiz.numbers.count {
            currentDisplayText = "\(currentQuiz.numbers[currentIndex])"
            currentIndex += 1
            if currentIndex == 1 { lastProblemStartTime = Date() }
        } else {
            currentDisplayText = "？"; isAnswering = true
        }
    }

    func check() {
        let interval = Date().timeIntervalSince(lastProblemStartTime ?? Date())
        solveIntervals.append(interval)
        if Int(userInput) == currentQuiz.answer { gameState = min(1.0, gameState + 0.12) }
        if gameState >= 1.0 { finish(won: true) } else { startNext() }
    }

    func update() {
        guard !isGameOver && currentIndex > 0 else { return }
        totalPlayTime += 0.05
        gameState -= 0.001
        if let ghost = ghostToBeat {
            let ghostTargetTime = ghost.solveIntervals.prefix(ghostSolvedCount + 1).reduce(0, +)
            if totalPlayTime >= ghostTargetTime && ghostSolvedCount < ghost.solveIntervals.count {
                gameState -= 0.08
                ghostSolvedCount += 1
            }
        }
        if gameState <= 0 { finish(won: false) }
    }

    func finish(won: Bool) {
        isGameOver = true; showResultDialog = true
        currentDisplayText = won ? "勝ち！" : "負け..."
    }

    var resultDialog: some View {
        VStack(spacing: 20) {
            Text("今回のタイムをゴーストとして保存しますか？")
            HStack(spacing: 30) {
                Button("No") { onBack() }
                Button("Yes") {
                    let rec = GhostRecord(mode: config.mode, configLabel: config.label, solveIntervals: solveIntervals, date: Date())
                    ghostManager.saveRecord(rec)
                    onBack()
                }.buttonStyle(.borderedProminent)
            }
        }.padding().background(Color.white).cornerRadius(15).shadow(radius: 10).padding()
    }

    var mainLabel: String { isSkipConfirmation ? "スキップ" : (isAnswering ? "確定" : (currentIndex == 0 ? "開始" : "次へ")) }
    var mainColor: Color { isSkipConfirmation ? .red : (isAnswering ? .orange : .green) }
}
