//
//  Untitled.swift
//  Sum-o
//
//  Created by 🐣 on 2026/02/25.
//
import SwiftUI


struct TutorialPageTemplate3: View {
    let showNextArrow: Bool
    
    // --- 要素の順番表示用 ---
    @State private var showTitle = false
    @State private var showAnimationBox = false
    @State private var showText1 = false
    @State private var showText2 = false
    @State private var showArrow = false
    
    // --- ⚔️ とっくみ合い＆ぶっ飛びアニメーション用 ---
    @State private var showCombined = true // true: とっくみ合い, false: バラバラ
    @State private var battleOffset: CGFloat = 0 // 押し合いの移動量
    @State private var frogOffset: CGFloat = 0 // ぶっ飛ぶカエルの移動量
    @State private var frogOpacity: Double = 1.0 // カエルの透明度
    @State private var frogRotation: Double = 0 // カエルの回転角度
    @State private var rabbitOffset: CGFloat = 0 // ★ 追加：残ったウサギの踏み込み移動量
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            VStack(spacing: h * 0.03) {
                Spacer()
                
                // ① タイトル
                Text("How to Win")
                    .font(.custom("Papyrus", size: w * 0.1))
                    .fontWeight(.bold)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : -20)
                
                // ② ⚔️ アニメーションエリア
                ZStack {
                    if showCombined {
                        // 【Phase 1】とっくみ合い（じわじわ右へ）
                        Image("Battle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: w * 0.4)
                            .offset(x: battleOffset)
                    } else {
                        // 【Phase 2】カエルぶっ飛び ＆ ウサギ踏み込み！
                        ZStack {
                            // 残ったウサギ（★ 固定値ではなく、アニメーションする変数に変更！）
                            Image("Player_rabbit")
                                .resizable()
                                .scaledToFit()
                                .frame(width: w * 0.35)
                                .offset(x: rabbitOffset)
                            
                            // 右へ飛んでいくカエル
                            Image("frog")
                                .resizable()
                                .scaledToFit()
                                .frame(width: w * 0.35)
                                .rotationEffect(.degrees(frogRotation))
                                .offset(x: frogOffset)
                                .opacity(frogOpacity)
                        }
                    }
                }
                .frame(height: h * 0.25)
                .opacity(showAnimationBox ? 1 : 0)
                .offset(y: showAnimationBox ? 0 : -20)
                
                // ③ 説明テキスト（How to win）
              Text("Push your opponent out to win!")
                .font(.custom("Papyrus", size: w * 0.06))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(showText1 ? 1 : 0)
                .offset(y: showText1 ? 0 : -20)
                                
                            
                Text("The 5-beads row is a gauge.\nColors change to show who's winning!")
                .font(.custom("Papyrus", size: w * 0.045))
                
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
                .opacity(showText2 ? 1 : 0)
                .offset(y: showText2 ? 0 : -20)
                
                Spacer()
                
                // ⑤ 矢印
                if showNextArrow {
                    VStack {
                        Image(systemName: "arrow.down")
                            .font(.system(size: w * 0.03))
                            // 矢印だけ「ふわふわ」上下に動かして誘導する
                            .offset(y: showArrow ? 2.5 : 0)
                            .animation(.easeInOut(duration: 0.6).repeatForever(), value: showArrow)
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
                startBattleLoop(w: w)
            }
        }
    }
    

    private func triggerRevealAnimations() {
        guard !showTitle else { return }
        Task {
            withAnimation(.easeOut(duration: 0.4)) { showTitle = true }
            try? await Task.sleep(nanoseconds: 200_000_000)
            withAnimation(.easeOut(duration: 0.4)) { showAnimationBox = true }
            try? await Task.sleep(nanoseconds: 300_000_000)
            withAnimation(.easeOut(duration: 0.4)) { showText1 = true }
            try? await Task.sleep(nanoseconds: 300_000_000)
            withAnimation(.easeOut(duration: 0.4)) { showText2 = true }
            try? await Task.sleep(nanoseconds: 300_000_000)
            withAnimation(.easeOut(duration: 0.4)) { showArrow = true }
        }
    }
    

    private func startBattleLoop(w: CGFloat) {
        Task {
            while !Task.isCancelled {
                // 1. 初期状態にリセット
                await MainActor.run {
                    showCombined = true
                    battleOffset = 0
                    frogOffset = w * 0.15
                    frogOpacity = 1.0
                    frogRotation = 0
                    rabbitOffset = w * 0.05 // ★ ウサギの初期位置（とっくみ合い分裂時の位置）
                }
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1秒待機
                
                // 2. じわじわ右に押し込む
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 1.5)) {
                        battleOffset = w * 0.15 // 右へ移動
                    }
                }
                try? await Task.sleep(nanoseconds: 1_500_000_000) // 押し切るまで待機
                
                // 3. 画像が分かれて、カエルがクルクル右へぶっ飛び、ウサギもグッと踏み込む！
                await MainActor.run {
                    showCombined = false
                    withAnimation(.easeOut(duration: 0.8)) {
                        frogOffset = w * 0.7 // カエルは画面外へ
                        frogOpacity = 0.0
                        frogRotation = 720
                        rabbitOffset = w * 0.15 // ★ 追加！ウサギも少し右にダッ！と踏み込む
                    }
                }
                try? await Task.sleep(nanoseconds: 2_500_000_000) // 余韻を残して最初に戻る
            }
        }
    }
}
