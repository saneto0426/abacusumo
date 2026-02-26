//
//  InteractiveTutorialView.swift
//  Sum-o
//
//  Created by 🐣 on 2026/02/24.
//
import SwiftUI


struct InteractiveTutorialView: View {
    @Environment(\.dismiss) var dismiss
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    
    // 🌟 チュートリアルの進行ステップ
    @State private var tutorialStep = 1
    
    // 本編と同じ状態管理
    @State private var isAnswering = false
    @State private var userInput = ""
    @State private var gameState: Double = 0.5
    
    @State private var handOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            let widthBase = w * (isPad ? 0.7 : 0.95)
            let heightBase = h * (isPad ? 0.49 : 0.85)
            let baseW = min(widthBase, heightBase)
            
            ZStack(alignment: .top) { // ★上寄せ配置にするため alignment: .top を指定
         
                Image("o_play_screen")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .clipped()
                    .ignoresSafeArea()
                
   
                VStack {
                                    
                    Text(instructionText)
                    .font(.custom("Papyrus", size: baseW * 0.05))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                                   
                    .padding(.horizontal, baseW * 0.05)
                    .padding(.vertical, baseW * 0.02)
                                        
                    .frame(width: baseW * 0.8, height: baseW * 0.6)
                                        
                                      
                    .background(
                    Image("option")
                      .resizable()
                      .frame(width: baseW * 0.8, height: baseW * 0.25)
                     )
                    .animation(.easeInOut, value: tutorialStep)
                                    
                                    // 上からの位置を調整
                    .padding(.top, h * (isPad ? -0.07: 0.18))
                                    
                    Spacer() // これで上に押し上げられます
                    }
                // このVStackを画面全体のレイヤーとして重ねる
                .frame(width: w, height: h)
                // 他の要素（ボードや力士）より手前に表示されるようにZIndexを上げる
                .zIndex(10)

                
                // --- ゲーム画面の要素（ボード、力士、テンキー） ---
                ZStack {
                    
                    // --- 【レイヤー1】 掲示板 ---
                    ZStack {
                        Image("board")
                            .resizable().scaledToFit()
                            .frame(width: baseW * 0.9)
                        
                        Text(displayText)
                            .font(.custom("Papyrus", size: baseW * 0.12)) // ★ パピルスに変更！
                            .fontWeight(.bold) // ★ 文字を太く見せたい場合は追加
                            .foregroundColor(tutorialStep == 7 ? .red : .black)
                            .contentTransition(.numericText())
                            .animation(.default, value: displayText)
                            .offset(y: baseW * 0.02)
                    }
                    .frame(height: baseW * 0.4)
                    .offset(y: -baseW * 0.55)
                    
                    // --- 【レイヤー2】 力士 ---
                    ZStack {
                        if tutorialStep == 7 {
                            HStack(spacing: baseW * 0.18) {
                                Image("Player_rabbit")
                                    .resizable().scaledToFit().frame(width: baseW * 0.4).offset(y: baseW * 0.43)
                                Image("frog")
                                    .resizable().scaledToFit().frame(width: baseW * 0.4).offset(y: baseW * 0.43)
                            }
                        } else {
                            Image("Battle")
                                .resizable().scaledToFit()
                                .offset(y: baseW * 0.42)
                                .frame(width: baseW * 0.4)
                                .offset(x: baseW * CGFloat(gameState - 0.5))
                                .animation(.interpolatingSpring(stiffness: 120, damping: 12), value: gameState)
                        }
                    }
                    .offset(y: -baseW * 0.5)
                    
                    // --- 【レイヤー3】 枠とゲージ ---
                    ZStack {
                        let frameW = baseW * 1.4
                        Image("frame")
                            .resizable().scaledToFit()
                            .frame(width: frameW)
                        
                        HStack(spacing: frameW * 0.025) {
                            let beadSize = frameW * 0.15
                            ForEach(0..<5, id: \.self) { i in
                                Image("key").resizable().scaledToFit()
                                    .frame(width: beadSize)
                                    .colorMultiply(gameState > (Double(i + 1) * 0.16) ? .white : .black)
                            }
                        }
                        .offset(y: frameW * -0.275)
                    }
                    .offset(y: baseW * 0.58)
                    
                    // --- 【レイヤー4】 チュートリアル専用テンキー ---
                    TutorialSorobanTenkey(
                        baseW: baseW,
                        suggestedKey: activeKeyForCurrentStep(),
                        handOffset: handOffset,
                        onAction: handleKeyInput
                    )
                    .offset(y: baseW * 0.7)
                    
                    Image("backFrame")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .clipped()
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
                .frame(width: w, height: h)
                
                // （以前の指示テキストの場所は削除しました）
                
                // 戻るボタン
                VStack {
                    HStack {
                        Button(action: { dismiss() }) {
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
                .zIndex(20) // 戻るボタンが一番手前に来るように
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    handOffset = baseW * 0.03
                }
            }
        }
    }
    
    // --- 🌟 表示ロジック ---
    
    private var displayText: String {
        if tutorialStep == 7 { return "WIN!" }
        if !isAnswering {
            if tutorialStep == 1 { return "READY" }
            if tutorialStep == 2 { return "1" }
            if tutorialStep == 3 { return "2" }
        } else {
            return userInput.isEmpty ? "?" : userInput
        }
        return ""
    }
    
    // フワフワ浮かぶ指示文
    private var instructionText: String {
        switch tutorialStep {
        case 1: return "Tap 'ST' to start!"
        case 2: return "Remember '1'.\nTap 'ST' for next."
        case 3: return "Add '2' (1 + 2 = ?)\nTap 'ST' to answer."
        case 4: return "What's the answer?\nType '3'!"
        case 5: return "Correct! Tap 'ST' to attack!"
        case 6: return "Oops! Tap 'C' to clear."
        case 7: return "WIN! You mastered the basics!"
        case 8: return "Enter a number first!"
        default: return ""
        }
    }
    
    // 指マーク（👆）を出すべきキー
    private func activeKeyForCurrentStep() -> String? {
        if [1, 2, 3, 5].contains(tutorialStep) { return "ST" }
        if [4, 8].contains(tutorialStep) { return "3" }
        if tutorialStep == 6 { return "C" }
        return nil
    }
    
    // --- 🌟 キー入力処理（本編の handleKeyInput を完全再現！） ---
    private func handleKeyInput(_ key: String) {
        if tutorialStep == 7 { return } // クリア後は何もしない
        
        // ★ S (ST) ボタンの処理
        if key == "ST" {
            if !isAnswering {
                // 回答モードじゃない時は、数字をめくる（nextStep）
                if tutorialStep == 1 {
                    withAnimation { tutorialStep = 2 }
                } else if tutorialStep == 2 {
                    withAnimation { tutorialStep = 3 }
                } else if tutorialStep == 3 {
                    // 全部めくり終わったら回答モードへ
                    withAnimation {
                        isAnswering = true
                        tutorialStep = 4
                    }
                }
            } else {
                // 回答モードの時にSTを押した時（check）
                if userInput.isEmpty {
                    withAnimation { tutorialStep = 8 } // 空押し警告
                } else if userInput == "3" {
                    withAnimation { tutorialStep = 7 }
                    withAnimation(.easeOut(duration: 1.0)) { gameState = 1.0 }
                } else {
                    withAnimation { tutorialStep = 6 } // 間違い
                }
            }
            return // STの処理が終わったら抜ける
        }
        
        // ★ 回答モードじゃない時は、数字を押しても無視する（本編と同じ！）
        if !isAnswering { return }
        
        // ★ 数字とCボタンの処理
        if key == "C" {
            userInput = ""
            withAnimation { tutorialStep = 4 }
        } else {
            if userInput.count < 8 {
                userInput += key
            }
            if userInput == "3" {
                withAnimation { tutorialStep = 5 } // 完璧
            } else {
                withAnimation { tutorialStep = 6 } // 間違い
            }
        }
    }
}

// （※ TutorialSorobanTenkey はそのままで大丈夫です！）

// --- 🌟 チュートリアル用テンキー（本編同様、すべてのキーが自由に押せる！） ---
struct TutorialSorobanTenkey: View {
    let baseW: CGFloat
    let suggestedKey: String? // 指マークを出すキー
    let handOffset: CGFloat
    let onAction: (String) -> Void
    
    private let columns = [
        ["1", "4", "7", "C"],
        ["2", "5", "8", "0"],
        ["3", "6", "9", "S"]
    ]

    var body: some View {
        HStack(spacing: baseW * 0.065) {
            
            // 左の飾り
            VStack {
                Spacer()
                Image("keys")
                    .resizable().scaledToFit().frame(width: baseW * 0.18)
                    .offset(y: -baseW * 0.165).allowsHitTesting(false)
                Spacer()
            }
            .frame(height: baseW * 0.8)
            
            // テンキー本体
            ForEach(0..<3, id: \.self) { col in
                VStack(spacing: baseW * 0.015) {
                    ForEach(columns[col], id: \.self) { key in
                        
                        let actualKey = key == "S" ? "ST" : key
                        // 今オススメされているキーかどうか
                        let isSuggested = (actualKey == suggestedKey)
                        
                        Button(action: {
                            onAction(actualKey)
                        }) {
                            ZStack {
                                Image("key")
                                    .resizable().scaledToFit()
                                    .frame(width: baseW * 0.2, height: baseW * 0.2)
                                
                                let labelColor = key == "S" ? Color.green : (key == "C" ? Color.red : Color.black)
                                Text(actualKey)
                                    .font(.custom("Papyrus", size: baseW * 0.08))
                                    .font(.system(size: key == "S" ? baseW * 0.04 : baseW * 0.08, weight: .black))
                                    .foregroundColor(labelColor)
                                    .offset(y: baseW * 0.01)
                            }
                            .frame(width: baseW * 0.18, height: baseW * 0.14)
                            .contentShape(Diamond())
                            .offset(y: -baseW * 0.08)
                            // 指マークをかぶせる
                            .overlay(
                                Group {
                                    if isSuggested {
                                        Image(systemName: "hand.point.up.fill")
                                            .font(.system(size: baseW * 0.1))
                                            .foregroundColor(.orange)
                                            .offset(x: baseW * 0.08, y: baseW * 0.05 + handOffset)
                                    }
                                }
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            // 右の飾り
            VStack {
                Spacer()
                Image("keys")
                    .resizable().scaledToFit().frame(width: baseW * 0.18)
                    .offset(y: -baseW * 0.165).allowsHitTesting(false)
                Spacer()
            }
            .frame(height: baseW * 0.8)
        }
    }
}
