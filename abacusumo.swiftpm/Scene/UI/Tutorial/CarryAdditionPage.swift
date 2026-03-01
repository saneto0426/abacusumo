//
//  CarryAdditionPage.swift
//  Sum-O
//
//  Created by 🐣 on 2026/03/01.
//

import SwiftUI

struct CarryAdditionPage: View {
    let showNextArrow: Bool
    
    // そろばんの状態
    @State private var ten_1_Active = false
    @State private var one_5_Active = true
    @State private var one_1_Count = 3 // 8 (5+3)
    
    // テキスト状態（★ 色を変えたい部分を * で囲んでいます）
    @State private var explanationText = "Start: We have *8*."
    
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            VStack(spacing: 0) {
                // ① 上部：説明文
                VStack {
                    Spacer()
                    // ★ formatTextを使って色分け！
                    formatText("Example: 8 + 3")
                        .font(.custom("Papyrus", size: w * 0.07))
                    Spacer()
                }
                .frame(width: w, height: h * 0.15)
                
                // 下部：アニメと解説のHStack
                HStack(spacing: 0) {
                    // ② 左下：アニメーションエリア
                    GeometryReader { animGeo in
                        let aw = animGeo.size.width
                        let ah = animGeo.size.height
                        let beadW = aw * 0.25
                        
                        ZStack {
                            // フレーム
                            Image("frame_t")
                                .resizable()
                                .scaledToFit()
                                .frame(width: aw * 0.9)
                            
                            // 珠（2列）
                            HStack(spacing: aw * 0.00001) {
                                // 十の位
                                VStack(spacing: 0) {
                                    beadImg(w: beadW).offset(y:  beadW * 0.05)
                                    Spacer().frame(height: beadW * 0.7)
                                    VStack(spacing: aw * -0.05) {
                                        beadImg(w: beadW).offset(y: ten_1_Active ? -beadW * 0.45 : 0)
                                        beadImg(w: beadW)
                                        beadImg(w: beadW)
                                        beadImg(w: beadW)
                                    }
                                }.offset(y: -aw * 0.0015)
                                
                                // 一の位
                                VStack(spacing: 0) {
                                    beadImg(w: beadW).offset(y: one_5_Active ? -beadW * 0.1 : -beadW * 0.4)
                                    Spacer().frame(height: beadW * 0.35)
                                    VStack(spacing: aw * -0.25) {
                                        ForEach(0..<4, id: \.self) { i in
                                            beadImg(w: beadW)
                                                .offset(y: lowerBeadOffset(index: i, activeCount: one_1_Count, beadW: beadW , aw: aw))
                                        }
                                        
                                    }.offset(y: aw * 0.01)
                                    
                                }.offset(y: -aw * 0.23)
                            }
                            .offset(x: aw * 0.105, y: -ah * 0.0025) // センター微調整
                            
                        }
                        // ★★★ ここを追加！！ ZStackをアニメーションエリアの「ど真ん中」に配置します ★★★
                        .frame(width: aw, height: ah)
                    }
                    .frame(width: w * 0.5, height: h * 0.75)
                    
                    // ③ 右下：解説文エリア
                    VStack {
                        Spacer()
                        // ★ formatTextを使って色分け！(黒ベース)
                        formatText(explanationText)
                            .font(.custom("Papyrus", size: w * (isPad ? 0.03 : 0.04)))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            // ★ 文字が見やすいように薄いグレーの背景を敷く
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.15)))
                            .padding(.trailing)
                        Spacer()
                    }
                    .frame(width: w * 0.45, height: h * 0.75)
                }
                
                // 矢印（最下部）
                if showNextArrow {
                    TutorialArrowView(w: w)
                        .padding(.bottom, h * 0.02)
                } else {
                    Spacer().frame(height: h * 0.05)
                }
            }
            .frame(width: w, height: h)
            .onAppear {
                startAnimationLoop(w: w, h: h)
            }
        }
    }
    
    // --- 🌟 *で囲んだ部分だけ赤くする魔法の関数 ---
    private func formatText(_ text: String) -> Text {
        let components = text.components(separatedBy: "*")
        var result = Text("")
        
        for (index, part) in components.enumerated() {
            if index % 2 == 1 {
                result = result + Text(part).foregroundColor(.red).fontWeight(.bold)
            } else {
                result = result + Text(part).foregroundColor(.black)
            }
        }
        return result
    }
    
    // --- 🌟 アニメーションロジック ---
    private func startAnimationLoop(w: CGFloat, h: CGFloat) {
        Task {
            while !Task.isCancelled {
                // Step 0: 初期状態 (8)
                updateState(t1: false, o5: true, o1: 3, text: "Start: We have *8*.")
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                
                // Step 1: 3を足そうとする
                updateState(text: "Want to add *3*.\nBut not enough beads!")
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                
                // Step 2: 思考 (友達は7)
                updateState(text: "*3*'s partner is *7*.\nSubtract *7*, add *10*.")
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                
                // Step 3: 一の位から7を引く (まず5を上げる)
                updateState(o5: false, text: "Subtracting *7*...\n(First, remove *5*)")
                try? await Task.sleep(nanoseconds: 1_200_000_000)
                
                // 1を2つ下げる
                updateState(o1: 1, text: "Subtracting *7*...\n(Then, remove *2*)")
                try? await Task.sleep(nanoseconds: 1_200_000_000)
                
                // Step 4: 十の位に1を足す
                updateState(text: "Now, carry over *10*\nby adding *1* bead here.")
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                
                updateState(t1: true)
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                
                // Step 5: 完成 (11)
                updateState(text: "Done! The answer is *11*.")
                try? await Task.sleep(nanoseconds: 3_000_000_000)
            }
        }
    }
    
    // --- ヘルパー関数群 ---
    @MainActor
    private func updateState(t1: Bool? = nil, o5: Bool? = nil, o1: Int? = nil, text: String? = nil) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let t1 = t1 { ten_1_Active = t1 }
            if let o5 = o5 { one_5_Active = o5 }
            if let o1 = o1 { one_1_Count = o1 }
            if let text = text { explanationText = text }
        }
    }
    
    private func lowerBeadOffset(index: Int, activeCount: Int, beadW: CGFloat, aw: CGFloat) -> CGFloat {
        let spacing = beadW * 0.75
        let baseY = CGFloat(index) * spacing
        let activeMove = -aw * 0.15
        
        let isActivated = index < activeCount
        return baseY + (isActivated ? activeMove : 0)
    }
}
