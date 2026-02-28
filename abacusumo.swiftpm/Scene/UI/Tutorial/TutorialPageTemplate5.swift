//
//  TutorialPageTemplate5.swift
//  Sum-o
//
//  Created by 🐣 on 2026/02/26.
//
import SwiftUI

// --- 🌟 遊び方の説明（アニメーションで見る6〜10の作り方＋手の操作！） ---
struct TutorialPageTemplate5: View {
    let showNextArrow: Bool
    
    // --- アニメーション制御用 ---
    @State private var animationStep = 0
    
    // 【球の状態】
    @State private var bead5IsActive = true
    @State private var beads1AreActive = [false, false, false, false]
    @State private var bead10_5IsActive = false
    @State private var beads10_1AreActive = [false, false, false, false]
    
    // 【手の状態制御用】
    @State private var showHandAdd1 = false
    @State private var handAdd1Offset: CGSize = .zero
    @State private var showHandClear = false

    // 表示用アニメーション
    @State private var showTitle = false
    @State private var showAbacus = false
    @State private var showText = false
    @State private var showArrow = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
  
            let beadSize = w * 0.14
            
            let frameWidth = w * 0.6
          
            
            VStack(spacing: h * 0.02) {
                Spacer(minLength: h * 0.05)
                
                Text("How to make 6~10")
                    .font(.custom("Papyrus", size: w * 0.08))
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : -20)
                
                // ② そろばんアニメーション本体
                ZStack {
                    // 1. フレーム画像
                    Image("frame_t") // ← あなたの素材名に変更
                        .resizable()
                        .scaledToFit()
                        // ★ フレームだけ独立してサイズを変えられるように変更！
                        .frame(width: frameWidth)
                        .offset(y: -beadSize * 0.1) // 梁の位置の微調整用

                    // 2. 球の配置と動き
                    HStack(spacing: beadSize * 0.15) {
                        // 【十の位の列】
                        VStack(spacing: 0) {
                            Image("key").resizable().scaledToFit().frame(width: beadSize)
                                .offset(x: beadSize * 0.5,y: bead10_5IsActive ?  beadSize * 0.5  : 0)
                            Spacer().frame(height: beadSize * 1.5)
                            
                            VStack(spacing: w * -0.0275) {
                                ForEach(0..<4, id: \.self) { i in
                                    Image("key").resizable().scaledToFit().frame(width: beadSize)
                                        .offset(x: beadSize * 0.5,y: beads10_1AreActive[i] ? -beadSize * 1.15: -w * 0.02)
                                }
                            }
                        }
                        // 【一の位の列】
                        VStack(spacing: 0) {
                            Image("key").resizable().scaledToFit().frame(width: beadSize)
                                .offset(x: beadSize * 0.5 ,y: bead5IsActive ? beadSize * 0.5  : 0)
                            Spacer().frame(height: beadSize * 1.5)
                            
                            VStack(spacing: w * -0.0275) {
                                ForEach(0..<4, id: \.self) { i in
                                    Image("key").resizable().scaledToFit().frame(width: beadSize)
                                        .offset(x: beadSize * 0.5,y: beads1AreActive[i] ? -beadSize * 1.15: -w * 0.02)
                                }
                            }
                        }
                    }
                  
                    .fixedSize()
                    .offset(y: w * 0.002)
                    
                    // 3. 【手のレイヤー】
                    ZStack {
                        Image("one") // ← あなたの素材名に変更
                            .resizable().scaledToFit()
                            .frame(width: beadSize * 3)
                            .offset(x: w * 0.175 ,y: -beadSize * 0.5)
                            .offset(handAdd1Offset)
                            .opacity(showHandAdd1 ? 1 : 0)
                        
                        Image("Clear") // ← あなたの素材名に変更
                            .resizable().scaledToFit()
                            .frame(width: beadSize * 3)
                            .offset(x: beadSize * 1.75, y: -beadSize * 0.5)
                            .opacity(showHandClear ? 1 : 0)
                    }
                    .animation(.easeInOut(duration: 0.3), value: showHandAdd1)
                    .animation(.easeInOut(duration: 0.3), value: showHandClear)
                    // ★ 手の画像も勝手に縮まないように保護！
                    .fixedSize()
                }
                .padding(.vertical, h * 0.05)
                .opacity(showAbacus ? 1 : 0)
                .offset(y: showAbacus ? 0 : -20)

                // ③ 説明テキスト
                Text(currentDisplayText)
                    .font(.custom("Papyrus", size: w * 0.07))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .contentTransition(.numericText())
                    .animation(.default, value: animationStep)
                    .frame(height: h * 0.1)
                    .opacity(showText ? 1 : 0)

                Spacer(minLength: 0)
                
                // ④ 矢印
                if showNextArrow {
                    VStack {
               
                        Image(systemName: "arrow.down").font(.system(size: w * 0.03))
                            .offset(y: showArrow ? 0 : -10)
                            .animation(.easeInOut(duration: 0.8).repeatForever(), value: showArrow)
                    }
                    .opacity(showArrow ? 1 : 0)
                    .padding(.bottom, h * 0.05)
                } else {
                    Spacer().frame(height: h * 0.1)
                }
            }
            .frame(width: w, height: h)
            .onAppear {
                            triggerRevealAnimations()
                            startAbacusLoop(beadSize: beadSize, w: w)
                        }
        }
    }
    
    // --- テキスト内容 ---
    private var currentDisplayText: String {
        switch animationStep {
        case 0: return "Start from 5."
        case 1: return "This is 6. (5+1)"
        case 2: return "This is 7. (5+2)"
        case 3: return "This is 8. (5+3)"
        case 4: return "This is 9. (5+4)"
        case 5: return "Clear!"
        case 6: return "And this is 10!"
        default: return ""
        }
    }
    
    // --- 順番表示アニメーション ---
    private func triggerRevealAnimations() {
        guard !showTitle else { return }
        Task {
            withAnimation(.easeOut(duration: 0.4)) { showTitle = true }
            try? await Task.sleep(nanoseconds: 300_000_000)
            withAnimation(.easeOut(duration: 0.4)) { showAbacus = true }
            try? await Task.sleep(nanoseconds: 300_000_000)
            withAnimation(.easeOut(duration: 0.4)) { showText = true }
            try? await Task.sleep(nanoseconds: 300_000_000)
            withAnimation(.easeOut(duration: 0.4)) { showArrow = true }
        }
    }
    

        private func startAbacusLoop(beadSize: CGFloat,w: CGFloat) {
            Task {
                while !Task.isCancelled {
                    // 1. 初期状態 (5)
                    await MainActor.run {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            animationStep = 0
                            bead5IsActive = true; beads1AreActive = [false,false,false,false]
                            beads10_1AreActive = [false,false,false,false]
                            showHandAdd1 = false; showHandClear = false
                        }
                    }
                    try? await Task.sleep(nanoseconds: 1_500_000_000)

                                    for i in 0..<4 {
                               
                                        await MainActor.run {
                                            handAdd1Offset = CGSize(
                                                width: beadSize * 0.55,
                                           
                                                height: beadSize * (1.2 +  Double(i) * 0.8)
                                            )
                                            showHandAdd1 = true
                                        }
                                        try? await Task.sleep(nanoseconds: 300_000_000)

                                        // ★② 3つ目、4つ目の移動距離を「ひかえめ」に！
                                        await MainActor.run {
                                            withAnimation(.easeInOut(duration: 0.4)) {
                                                animationStep = i + 1
                                                beads1AreActive[i] = true
                                                
                                                // 🌟 ここがポイント！
                                          
                                                let moveDistance = beadSize * (1.2 + Double(i) * 0.2)
                                                handAdd1Offset.height -= moveDistance
                                            }
                                        }
                                        try? await Task.sleep(nanoseconds: 500_000_000)
                                        
                                        // ★③ 手を隠す
                                        await MainActor.run {
                                            showHandAdd1 = false
                                        }
                                        try? await Task.sleep(nanoseconds: 300_000_000)
                                    }
                    try? await Task.sleep(nanoseconds: 500_000_000)

                    // 3. 「弾く」アクション（ここはそのまま）
                    await MainActor.run {
                        showHandClear = true
                    }
                    try? await Task.sleep(nanoseconds: 300_000_000)

                    await MainActor.run {
                        withAnimation(.easeOut(duration: 0.2)) {
                            animationStep = 5
                            bead5IsActive = false
                            beads1AreActive = [false,false,false,false]
                        }
                        showHandClear = false
                    }
                    try? await Task.sleep(nanoseconds: 400_000_000)

                    // 4. 10にする
                    // ★① 十の位の「弾く前」の位置に手をスタンバイ
                    await MainActor.run {
                        handAdd1Offset = CGSize(
                            width: -beadSize * 0.75,
                            height: beadSize * 1.0 // 十の位の一番上の玉の高さ
                        )
                        showHandAdd1 = true
                    }
                    try? await Task.sleep(nanoseconds: 300_000_000)

                    // ★② 玉と同時に手も上にスライド！
                    await MainActor.run {
                        withAnimation(.easeOut(duration: 0.5)) {
                            animationStep = 6
                            beads10_1AreActive[0] = true
                            
                            // ここでも手を上に動かす！
                            handAdd1Offset.height -= beadSize
                        }
                    }
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    
                    // ★③ 手を隠す
                    await MainActor.run {
                        showHandAdd1 = false
                    }
                    try? await Task.sleep(nanoseconds: 2_500_000_000)
                }
            }
        }
}
