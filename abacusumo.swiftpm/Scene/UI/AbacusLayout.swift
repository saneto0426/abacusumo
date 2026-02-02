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
            
            // ★ベース幅の定義 (iPad: 60%, iPhone: 92%)
            // この数字をいじるだけで全体のサイズが変わります
            let baseW = w * (isPad ? 0.60 : 0.92)
            
            VStack(spacing: 0) {
                // (A) 上の余白
                Spacer().frame(height: h * (isPad ? 0.15 : 0.12))
                
                // (B) 掲示板
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
                .zIndex(0)
                
                // (C) 力士
                ZStack {
                    Color.clear.frame(height: baseW * 0.01)
                    if currentDisplayText == "READY" || isGameOver {
                        HStack(spacing: baseW * 0.18) {
                            Image("sumo_rikishi_harite2")
                                .resizable().scaledToFit().frame(width: baseW * 0.28)
                            Image("sumo_rikishi_harite2")
                                .resizable().scaledToFit().frame(width: baseW * 0.28).scaleEffect(x: -1)
                        }
                    } else {
                        Image("sumo_torikumi")
                            .resizable().scaledToFit()
                            .frame(width: baseW * 0.35)
                            .offset(x: baseW * CGFloat(gameState - 0.5))
                    }
                }
                .padding(.bottom, baseW * -0.06)
                .zIndex(2)
                
                // (D) 枠とゲージ
                ZStack {
                    Image("frame")
                        .resizable().scaledToFit().frame(width: baseW)
                    
                    HStack(spacing: baseW * 0.025) {
                        let beadSize = baseW * 0.13
                        ForEach(0..<5) { i in
                            Image("key").resizable().scaledToFit()
                                .frame(width: beadSize)
                                .colorMultiply(gameState > (Double(i + 1) * 0.16) ? .white : .black)
                        }
                    }
                    .offset(y: baseW * 0.065)
                }
                .zIndex(1)
                
                // (E) テンキー配置
                // 枠の幅(baseW)をSorobanTenkeyに渡して、完璧なサイズで描画させます
                SorobanTenkey(
                    baseW: baseW,
                    isGameOver: isGameOver,
                    isAnswering: isAnswering,
                    onAction: onKeyInput
                )
                .padding(.top, baseW * 0.03)
                
                Spacer()
            }
            .frame(width: w)
        }
    }
}
