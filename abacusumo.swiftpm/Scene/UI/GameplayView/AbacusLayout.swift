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
            
           
            let widthBase = w * (isPad ? 0.7 : 0.95)
            
           
            let heightBase = h * (isPad ? 0.49 : 0.85)
            
     
            let baseW = min(widthBase, heightBase)
       
            ZStack {
                
                // --- 【レイヤー1】 掲示板 (一番上) ---
                ZStack {
                    // 1. まず「土台」となる掲示板を表示
                    Image("board")
                        .resizable()
                        // 掲示板自体のサイズを固定（ここが動くとレイアウトが崩れる原因になります）
                        .frame(width: baseW * 0.5, height: baseW * 0.5)
                        .overlay(
                            // 2. その上にコンテンツを「重ねる」
                            Group {
                                if currentDisplayText == "READY" {
                                    Image("Gunpai")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: baseW * 0.4, height: baseW * 0.4)
                                        .offset(y: baseW * 0.03)
                                } else {
                                    Text(isAnswering ? (userInput.isEmpty ? "?" : userInput) : currentDisplayText)
                          
                                        .font(.system(size: baseW * 0.2, weight: .heavy, design: .rounded))
                                        .foregroundColor(showEmptyWarning ? .red : .black)
                                        
                                        
                                        .frame(width: baseW * 0.45)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                        .offset(y: baseW * 0.045)
                                }
                            }
                        )
                }
                // レイヤー全体の枠組み
                .frame(height: baseW * 0.4)
                .offset(y: -baseW * 0.55)
                
                // --- 【レイヤー2】 力士 (掲示板と枠の間) ---
                ZStack {
                    if currentDisplayText == "READY" || isGameOver {
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
                
                
                // --- 【レイヤー3】 枠とゲージ (真ん中) ---
                ZStack {
        
                    let frameW = baseW * 1.325
                    
                    Image("frame")
                        .resizable().scaledToFit()
                        .frame(width: frameW)
                    
                    HStack(spacing: frameW * 0.025) {
                        let beadSize = frameW * 0.15
                        ForEach(0..<5) { i in
                            Image("key").resizable().scaledToFit()
                                .frame(width: beadSize)
                                .colorMultiply(gameState > (Double(i + 1) * 0.16) ? .white : .black)
                        }
                    }
              
                    .offset(y: frameW * -0.275)
                }
           
                .offset(y: baseW * 0.58)
                
                
                // --- 【レイヤー4】 テンキー (一番下) ---
                SorobanTenkey(
                    baseW: baseW,
                    isGameOver: isGameOver,
                    isAnswering: isAnswering,
                    onAction: onKeyInput
                )
                // 位置指定: 枠の下 (+0.7 くらい)
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
        }
    }
    
}
