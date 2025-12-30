//
//  BattleView.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/20.
//
import SwiftUI

struct GameView: View {
    let mode: GameMode
    var onBackToTitle: () -> Void

    private var generator: ProblemGeneratable {
        switch mode {
        case .addition: return SimpleProblemGenerator()
        case .multiplication: return MultiProblemGenerator()
        case .division: return DivProblemGenerator()
        }
    }
    
    private var config: LevelConfig {
        switch mode {
        case .multiplication, .division:
            return LevelConfig(digits: 2, count: 2, allowSubtraction: false)
        default:
            return LevelConfig(digits: 2, count: 5, allowSubtraction: true)
        }
    }

    @State private var gameState: Double = 0.5
    @State private var isGameOver = false
    @State private var wonGame = false
    
    @State private var currentQuiz: (numbers: [Int], answer: Int) = ([], 0)
    @State private var currentIndex = 0
    @State private var currentDisplayText: String = "準備完了"
    @State private var userInput: String = ""
    @State private var isAnswering = false
    // ★ 追加：空欄で押した時の確認フラグ ★
    @State private var isSkipConfirmation = false

    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            BattleBarComponent(value: gameState)
                .padding(.top, 60)
                .padding(.bottom, 30)

            VStack(spacing: 10) {
                Text(currentDisplayText)
                    .font(.system(size: 80, weight: .bold, design: .monospaced))
                    .foregroundColor(isAnswering ? .secondary : .primary)
                
                HStack {
                    Text("入力:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(userInput)
                        .font(.system(size: 45, weight: .bold, design: .monospaced))
                        .frame(minWidth: 120, minHeight: 60)
                        .background(isSkipConfirmation ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
            }
            .frame(maxHeight: .infinity)

            // テンキー
            NumberPad(
                userInput: $userInput,
                actionLabel: mainActionLabel,
                actionColor: mainActionColor
            ) {
                handleMainAction()
            }
            .onChange(of: userInput) { _ in
                // 文字が入力されたら確認状態を解除する
                if !userInput.isEmpty { isSkipConfirmation = false }
            }
            .padding(.bottom, 40)
            .background(Color.gray.opacity(0.05))
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear { setupFirstGame() }
        .onReceive(timer) { _ in updateBar() }
    }

    // 右下ボタンのラベル
    var mainActionLabel: String {
        if isGameOver { return "リトライ" }
        if isSkipConfirmation { return "スキップ" } // 未入力1回押した後の表示
        if isAnswering { return "確定" }
        if currentIndex == 0 { return "開始" }
        return "次へ"
    }

    var mainActionColor: Color {
        if isGameOver { return .blue }
        if isSkipConfirmation { return .red }
        if isAnswering { return .orange }
        return .green
    }

    // --- ゲームロジック ---
    
    func handleMainAction() {
        if isGameOver {
            resetGame()
        } else if isAnswering {
            if userInput.isEmpty {
                // ★ 未入力の場合の処理 ★
                if isSkipConfirmation {
                    isSkipConfirmation = false
                    startNextQuiz() // 2回目なので次へ
                } else {
                    isSkipConfirmation = true // 1回目：警告状態へ
                }
            } else {
                isSkipConfirmation = false
                checkAnswer()
            }
        } else {
            nextStep()
        }
    }

    func setupFirstGame() {
        currentQuiz = generator.makeQuiz(config: config)
        currentIndex = 0
        currentDisplayText = "準備完了"
        isAnswering = false
        userInput = ""
        isSkipConfirmation = false
    }

    func startNextQuiz() {
        currentQuiz = generator.makeQuiz(config: config)
        currentIndex = 0
        userInput = ""
        isAnswering = false
        isSkipConfirmation = false
        nextStep()
    }

    func nextStep() {
        if currentIndex < currentQuiz.numbers.count {
            let num = currentQuiz.numbers[currentIndex]
            currentDisplayText = "\(num)"
            currentIndex += 1
        } else {
            currentDisplayText = "？"
            isAnswering = true
        }
    }

    func updateBar() {
        guard !isGameOver && currentIndex > 0 else { return }
        gameState -= 0.002
        if gameState <= 0 { finishGame(won: false) }
    }

    func checkAnswer() {
        let userAnswerInt = Int(userInput) ?? 0
        if userAnswerInt == currentQuiz.answer {
            gameState = min(1.0, gameState + 0.15)
        }
        // 不正解でもバーは減らさない（一定の動き）

        if gameState >= 1.0 {
            finishGame(won: true)
        } else {
            startNextQuiz()
        }
    }

    func finishGame(won: Bool) {
        isGameOver = true
        wonGame = won
        currentDisplayText = won ? "勝ち！" : "負け..."
        isAnswering = false
    }

    func resetGame() {
        gameState = 0.5
        isGameOver = false
        setupFirstGame()
    }
}

// --- 部品 ---

struct NumberPad: View {
    @Binding var userInput: String
    let actionLabel: String
    let actionColor: Color
    var onAction: () -> Void
    let rows = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"]]
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<3) { rowIndex in
                HStack(spacing: 12) {
                    ForEach(rows[rowIndex], id: \.self) { label in
                        NumberButton(label: label) { userInput += label }
                    }
                }
            }
            HStack(spacing: 12) {
                NumberButton(label: "C", color: .red.opacity(0.8)) { userInput = "" }
                NumberButton(label: "0") { userInput += "0" }
                Button(action: onAction) {
                    Text(actionLabel).font(.headline).bold()
                        .frame(width: 80, height: 60)
                        .background(actionColor).foregroundColor(.white).cornerRadius(12)
                }
            }
        }
    }
}

struct NumberButton: View {
    let label: String
    var color: Color = .gray
    var action: () -> Void
    var body: some View {
        Button(action: { if label.count < 6 { action() } }) {
            Text(label).font(.title2).bold()
                .frame(width: 80, height: 60)
                .background(color).foregroundColor(.white).cornerRadius(12)
        }
    }
}

struct BattleBarComponent: View {
    var value: Double
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.gray.opacity(0.2))
                Capsule()
                    .fill(value < 0.3 ? Color.red : (value > 0.7 ? Color.blue : Color.green))
                    .frame(width: geo.size.width * CGFloat(value))
                    .animation(.linear, value: value)
            }
        }
        .frame(height: 25).padding(.horizontal)
    }
}
