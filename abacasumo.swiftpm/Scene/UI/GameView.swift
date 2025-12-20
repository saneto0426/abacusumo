//
//  BattleView.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/20.
//
import SwiftUI

struct GameView: View {
    // ★ ここを追加：親から受け取る設定 ★
    let mode: GameMode
    var onBackToTitle: () -> Void

    // モードに合わせて使うジェネレーターを切り替える
    private var generator: ProblemGeneratable {
        switch mode {
        case .addition: return SimpleProblemGenerator()
        case .multiplication: return MultiProblemGenerator()
        case .division: return DivProblemGenerator()
        }
    }
    
    // 桁数の設定（モードごとに変えることも可能です）
    private var config: LevelConfig {
        switch mode {
        case .multiplication, .division:
            return LevelConfig(digits: 2, count: 2, allowSubtraction: false)
        default:
            return LevelConfig(digits: 2, count: 5, allowSubtraction: true)
        }
    }
    // --- ゲーム全体の状態 ---
    @State private var gameState: Double = 0.5
    @State private var isGameOver = false
    @State private var wonGame = false
    
    // --- 問題と入力の状態 ---
    @State private var currentQuiz: (numbers: [Int], answer: Int) = ([], 0)
    @State private var currentIndex = 0
    @State private var currentDisplayText: String = "準備完了"
    @State private var userInput: String = ""
    @State private var isAnswering = false

    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            // 1. 【上段】勝敗バー
            BattleBarComponent(value: gameState)
                .padding(.top, 60)
                .padding(.bottom, 30)

            // 2. 【中段】メイン表示エリア
            VStack(spacing: 10) {
                Text(currentDisplayText)
                    .font(.system(size: 80, weight: .bold, design: .monospaced))
                    .foregroundColor(isAnswering ? .secondary : .primary)
                
                // 入力中の数字（視認性を高めるため少し大きめに）
                HStack {
                    Text("入力:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(userInput)
                        .font(.system(size: 45, weight: .bold, design: .monospaced))
                        .frame(minWidth: 120, minHeight: 60)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
            }
            .frame(maxHeight: .infinity)

            // 3. 【最下段】操作系が集約されたテンキー
            // 右下のボタンに現在の状態（開始/次へ/確定）を渡します
            NumberPad(
                userInput: $userInput,
                actionLabel: mainActionLabel,
                actionColor: mainActionColor
            ) {
                handleMainAction()
            }
            .padding(.bottom, 40)
            .background(Color.gray.opacity(0.05))
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear { prepareNewQuiz() }
        .onReceive(timer) { _ in updateBar() }
    }

    // --- 右下ボタンの動的な表示切り替え ---
    var mainActionLabel: String {
        if isGameOver { return "リトライ" }
        if isAnswering { return "確定" }
        if currentIndex == 0 { return "開始" }
        return "次へ"
    }

    var mainActionColor: Color {
        if isGameOver { return .blue }
        if isAnswering { return .orange }
        return .green
    }

    // --- ゲームロジック ---
    
    func handleMainAction() {
        if isGameOver {
            resetGame()
        } else if isAnswering {
            checkAnswer()
        } else {
            nextStep()
        }
    }

    func prepareNewQuiz() {
        currentQuiz = generator.makeQuiz(config: config)
        currentIndex = 0
        currentDisplayText = "準備完了"
        isAnswering = false
        userInput = ""
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
        guard !isGameOver else { return }
        gameState -= 0.002
        if gameState <= 0 { finishGame(won: false) }
    }

    func checkAnswer() {
        let userAnswerInt = Int(userInput) ?? 0
        if userAnswerInt == currentQuiz.answer {
            gameState = min(1.0, gameState + 0.15)
            if gameState >= 1.0 {
                finishGame(won: true)
            } else {
                prepareNewQuiz()
            }
        } else {
            userInput = "" // 間違えたらやり直し
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
        prepareNewQuiz()
    }
}

// --- 部品：高機能テンキー ---
struct NumberPad: View {
    @Binding var userInput: String
    let actionLabel: String
    let actionColor: Color
    var onAction: () -> Void
    
    let rows = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["C", "0"] // 右下は個別に作成するためここには含めない
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            // 1〜9段目
            ForEach(0..<3) { rowIndex in
                HStack(spacing: 12) {
                    ForEach(rows[rowIndex], id: \.self) { label in
                        NumberButton(label: label) { userInput += label }
                    }
                }
            }
            
            // 最下段（C, 0, アクションボタン）
            HStack(spacing: 12) {
                // クリアボタン
                NumberButton(label: "C", color: .red.opacity(0.8)) { userInput = "" }
                
                // 0ボタン
                NumberButton(label: "0") { userInput += "0" }
                
                // ★ ここが「開始・次へ・確定」を兼ねるメインボタン ★
                Button(action: onAction) {
                    Text(actionLabel)
                        .font(.headline).bold()
                        .frame(width: 80, height: 60)
                        .background(actionColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
    }
}

// 共通の数字ボタン部品
struct NumberButton: View {
    let label: String
    var color: Color = .gray
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            if label.count < 6 { action() }
        }) {
            Text(label)
                .font(.title2).bold()
                .frame(width: 80, height: 60)
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
}

// 勝敗バー部品（再掲）
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
        .frame(height: 25)
        .padding(.horizontal)
    }
}
