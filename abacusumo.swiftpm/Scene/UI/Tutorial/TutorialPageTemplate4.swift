//
//  TutorialPageTemplate4.swift
//  Sum-o
//
//  Created by 🐣 on 2026/02/26.
//
import SwiftUI


struct TutorialPageTemplate4: View {
    let showNextArrow: Bool
    
    // 表示アニメーション用
    @State private var showGaugeText = false
    @State private var showImages = false
    @State private var showModes = false
    @State private var showArrow = false
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            VStack(spacing: h * 0.015) {
                Spacer(minLength: 0)
                
                // ① バー（ゲージ）の説明テキスト
                Text("The 5-beads row is a gauge.\nColors change to show who's winning!")
                    .font(.custom("Papyrus", size: w * 0.048))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(showGaugeText ? 1 : 0)
                    .offset(y: showGaugeText ? 0 : -20)
                
                // ② 🌟 3枚の画像（横にテキストを添える！）
                VStack(spacing: h * 0.015) {
                    
                    // --- 1. Default (初期状態) ---
                    HStack(spacing: w * 0.02) {
                        Text("Default")
                            .font(.custom("Papyrus", size: w * 0.045))
                            .foregroundColor(.gray)
                            // 文字の横幅を固定して、縦のラインを綺麗に揃える
                            .frame(width: w * 0.2, alignment: .leading)
                        
                        Image("state_initial")
                            .resizable()
                            .scaledToFit()
                            .frame(width: w * 0.65) // 文字のスペースを確保するため 0.65 に
                    }
                    
                    // --- 2. Win (勝利) ---
                    HStack(spacing: w * 0.02) {
                        Text("Win!")
                            .font(.custom("Papyrus", size: w * 0.045))
                            .foregroundColor(.orange)
                            .fontWeight(.bold)
                            .frame(width: w * 0.2, alignment: .leading)
                        
                        Image("state_win")
                            .resizable()
                            .scaledToFit()
                            .frame(width: w * 0.65)
                    }
                    
                    // --- 3. Lose (敗北) ---
                    HStack(spacing: w * 0.02) {
                        Text("Lose...")
                            .font(.custom("Papyrus", size: w * 0.045))
                            .foregroundColor(.blue)
                            .frame(width: w * 0.2, alignment: .leading)
                        
                        Image("state_lose")
                            .resizable()
                            .scaledToFit()
                            .frame(width: w * 0.65)
                    }
                }
                .opacity(showImages ? 1 : 0)
                .offset(y: showImages ? 0 : -20)
                
                // ③ モードの説明
                VStack(alignment: .leading, spacing: h * 0.02) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Solo Mode:")
                            .font(.custom("Papyrus", size: w * 0.05))
                            .fontWeight(.bold)
                        Text("Enemy steadily pushes you back every second.")
                            .font(.custom("Papyrus", size: w * 0.04))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Ghost Mode:")
                            .font(.custom("Papyrus", size: w * 0.05))
                            .fontWeight(.bold)
                        Text("Opponent pushes back based on their solve speed.")
                            .font(.custom("Papyrus", size: w * 0.04))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, w * 0.08)
                .padding(.top, h * 0.01)
                .opacity(showModes ? 1 : 0)
                .offset(y: showModes ? 0 : -20)
                
                Spacer(minLength: 0)
                
                // ④ 矢印
                if showNextArrow {
                    VStack {

                        Image(systemName: "arrow.down")
                            .font(.system(size: w * 0.03))
                            .offset(y: showArrow ? 0 : -10)
                            .animation(.easeInOut(duration: 0.8).repeatForever(), value: showArrow)
                    }
                    .opacity(showArrow ? 1 : 0)
                    .padding(.bottom, h * 0.02)
                } else {
                    Spacer().frame(height: h * 0.05)
                }
            }
            .frame(width: w, height: h)
            .onAppear {
                triggerRevealAnimations()
            }
        }
    }
    
    // --- 🌟 順番にフワッと表示するアニメーション ---
    private func triggerRevealAnimations() {
        guard !showGaugeText else { return }
        Task {
            withAnimation(.easeOut(duration: 0.4)) { showGaugeText = true }
            try? await Task.sleep(nanoseconds: 300_000_000)
            withAnimation(.easeOut(duration: 0.4)) { showImages = true }
            try? await Task.sleep(nanoseconds: 300_000_000)
            withAnimation(.easeOut(duration: 0.4)) { showModes = true }
            try? await Task.sleep(nanoseconds: 300_000_000)
            withAnimation(.easeOut(duration: 0.4)) { showArrow = true }
        }
    }
}
