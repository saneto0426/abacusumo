//
//  AbacusLayout.swift
//  Sum-o
//
//  Created by 🐣 on 2026/01/28.
//

import SwiftUI

struct AbacusLayout: View {
    let isPad: Bool
    let gameState: Double
    let currentDisplayText: String
    let userInput: String
    let isAnswering: Bool
    let isGameOver: Bool
    let showEmptyWarning: Bool
    let onKeyInput: (String) -> Void

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
                        
            // ★ここを修正（魔法の3行）
            // 1. 横幅から計算したサイズ（今まで通り）
            let widthBase = w * (isPad ? 0.7 : 0.95)
                        
            // 2. 高さから計算したサイズ（13インチ対策：縦にはみ出さない限界値）
            let heightBase = h * (isPad ? 0.49 : 0.85)
                        
            // 3. 小さい方を採用！
            // これで「11インチは横幅ピッタリ」「13インチは高さピッタリ」になります
            let baseW = min(widthBase, heightBase)
            
            // ★ 全体を ZStack (レイヤー重ね) で自由に配置する方式 ★
            ZStack {
                
                // --- 【レイヤー1】 掲示板 (一番上) ---
                ZStack {
                    Image("board")
                        .resizable().scaledToFit()
                        .frame(width: baseW * 0.7)
                    
                    Text(isAnswering ? (userInput.isEmpty ? "?" : userInput) : currentDisplayText)
                        .font(.system(size: baseW * 0.12, weight: .black, design: .monospaced))
                        .foregroundColor(showEmptyWarning ? .red : .black)
                        .offset(y: baseW * 0.02)
                }
                .frame(height: baseW * 0.4)
                // 位置指定: 上の方へ (-0.55 くらいが丁度いい位置です)
                .offset(y: -baseW * 0.55)
                
                
                // --- 【レイヤー2】 力士 (掲示板と枠の間) ---
                ZStack {
                    if currentDisplayText == "READY" || isGameOver {
                        HStack(spacing: baseW * 0.18) {
                            Image("sumo_rikishi_harite2")
                                .resizable().scaledToFit().frame(width: baseW * 0.28).offset(y: baseW * 0.475)
                            Image("sumo_rikishi_harite2")
                                .resizable().scaledToFit().frame(width: baseW * 0.28).scaleEffect(x: -1).offset(y: baseW * 0.475)
                        }
                    } else {
                        Image("sumo_torikumi")
                            .resizable().scaledToFit()
                            .offset(y: baseW * 0.5)
                            .frame(width: baseW * 0.35)
                            .offset(x: baseW * CGFloat(gameState - 0.5))
                    }
                }
                // 位置指定: ちょっと上 (-0.2 くらい)
                .offset(y: -baseW * 0.5)
                
                
                // --- 【レイヤー3】 枠とゲージ (真ん中) ---
                ZStack {
                    // ★ ここでフレームをデカく設定 (1.3倍)
                    let frameW = baseW * 1.325
                    
                    Image("frame")
                        .resizable().scaledToFit()
                        .frame(width: frameW)
                    
                    HStack(spacing: frameW * 0.0275) {
                        let beadSize = frameW * 0.15
                        ForEach(0..<5) { i in
                            Image("key").resizable().scaledToFit()
                                .frame(width: beadSize)
                                .colorMultiply(gameState > (Double(i + 1) * 0.16) ? .white : .black)
                        }
                    }
                    // フレーム内での玉の位置調整
                    .offset(y: frameW * -0.225)
                }
                // 位置指定: 画面中央より少し下 (+0.15 くらい)
                .offset(y: baseW * 0.525)
                
                
                // --- 【レイヤー4】 テンキー (一番下) ---
                SorobanTenkey(
                    baseW: baseW,
                    isGameOver: isGameOver,
                    isAnswering: isAnswering,
                    onAction: onKeyInput
                )
                // 位置指定: 枠の下 (+0.7 くらい)
                .offset(y: baseW * 0.7)
                
            }
            .frame(width: w, height: h) // 画面いっぱいに広げる
        }
    }
}
