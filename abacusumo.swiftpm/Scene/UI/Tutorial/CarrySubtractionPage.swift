//
//  Untitled.swift
//  Sum-O
//
//  Created by 🐣 on 2026/03/01.
//

import SwiftUI

struct CarrySubtractionPage: View {
    let showNextArrow: Bool
    
    // そろばんの状態
    @State private var ten_1_Active = true
    @State private var one_5_Active = false
    @State private var one_1_Count = 1 // 11
    
    // ★ 手に関連する状態変数はすべて削除しました
    
    // テキスト状態（★ 色を変えたい部分を * で囲んでいます）
    @State private var explanationText = "Start: We have *11*."
    
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            VStack(spacing: 0) {
                // ① 上部
                VStack {
                    Spacer()
                    // ★ formatTextを使って色分け！
                    formatText("Example: 11 - 3")
                        .font(.custom("Papyrus", size: w * 0.07))
                    Spacer()
                }
                .frame(width: w, height: h * 0.15)
                
                HStack(spacing: 0) {
                    // ② 左下：アニメ
                    GeometryReader { animGeo in
                        let aw = animGeo.size.width
                        let ah = animGeo.size.height
                        // ★ 玉のサイズを足し算ページと統一
                        let beadW = aw * 0.25
                        
                        ZStack {
                            Image("frame_t")
                                .resizable()
                                .scaledToFit()
                                .frame(width: aw * 0.9)
                            
                            // 珠（2列）★ 足し算ページで調整された配置をそのままコピー！
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
                            
                            // ★ 手の画像は削除しました
                        }
                        .frame(width: aw, height: ah)
                    }
                    .frame(width: w * 0.5, height: h * 0.75) // ★ widthを0.5に統一
                    
                    // ③ 右下：解説
                    VStack {
                        Spacer()
                        // ★ formatTextを使って色分け！（黒ベース）
                        formatText(explanationText)
                            .font(.custom("Papyrus", size: w * (isPad ? 0.03 : 0.04)))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            // ★ 薄いグレーの背景を敷く
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.15)))
                            .padding(.trailing)
                        Spacer()
                    }
                    .frame(width: w * 0.45, height: h * 0.75)
                }
                
                if showNextArrow {
                    TutorialArrowView(w: w).padding(.bottom, h * 0.02)
                } else {
                    Spacer().frame(height: h * 0.05)
                }
            }
            .frame(width: w, height: h)
            .onAppear { startAnimationLoop() } // 引数不要にしたのでスッキリ
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
                result = result + Text(part).foregroundColor(.black).fontWeight(.bold)
            }
        }
        return result
    }
    
    // --- 🌟 アニメーションロジック（手のアクション削除＆スッキリ化） ---
    private func startAnimationLoop() {
        Task {
            while !Task.isCancelled {
                // Step 0: 初期状態 (11)
                updateState(t1: true, o5: false, o1: 1, text: "Start: We have *11*.")
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                
                // Step 1: 3を引こうとする
                updateState(text: "Want to subtract *3*.\nBut we only have *1* bead here.")
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                
                // Step 2: 思考 (繰り下がり、友達は7)
                updateState(text: "Borrow *10*,\nthen add *3*'s partner (*7*).")
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                
                // Step 3: 十の位から1を引く
                updateState(t1: false, text: "Borrowing *10*...")
                try? await Task.sleep(nanoseconds: 1_200_000_000)
                
                // Step 4: 一の位に7を足す (まず5を足す)
                updateState(o5: true, text: "Now, add partner *7*.\n(First, add *5*)")
                try? await Task.sleep(nanoseconds: 1_200_000_000)
                
                // 1を2つ上げる
                updateState(o1: 3, text: "Now, add partner *7*.\n(Then, add *2*)")
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                
                // Step 5: 完成 (8)
                updateState(text: "Done! The answer is *8*.")
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
    
    // ★ updateHand, hideHand の関数は削除しました！
    
    private func lowerBeadOffset(index: Int, activeCount: Int, beadW: CGFloat, aw: CGFloat) -> CGFloat {
        let spacing = beadW * 0.75
        let baseY = CGFloat(index) * spacing
        let activeMove = -aw * 0.15
        
        let isActivated = index < activeCount
        return baseY + (isActivated ? activeMove : 0)
    }
}

// ==========================================
// ★注意: 以下の共通部品は、もし「CarryAdditionPage.swift」などに
// 既に書かれている場合はエラー（重複）になるので消してください！
// （※手を管理する enum HandType は完全に不要になったので消しました）
// ==========================================

struct beadImg: View {
    let w: CGFloat
    var body: some View {
        Image("key")
            .resizable()
            .scaledToFit()
            .frame(width: w)
    }
}

struct TutorialArrowView: View {
    let w: CGFloat
    @State private var animArrow = false
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: "arrow.down")
                .font(.system(size: w * 0.03))
                .foregroundColor(.black)
                .offset(y: animArrow ? 0 : -10)
                .animation(.easeInOut(duration: 0.8).repeatForever(), value: animArrow)
        }
        .onAppear { animArrow = true }
    }
}
