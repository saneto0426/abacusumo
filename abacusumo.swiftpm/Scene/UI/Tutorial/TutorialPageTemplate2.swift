//
//  Untitled.swift
//  Sum-o
//
//  Created by 🐣 on 2026/02/24.
//

import SwiftUI

// --- 🌟 「How to use」専用のページ（アクション完全再現版） ---
struct TutorialPageTemplate2: View {
    let showNextArrow: Bool
    
    // 表示順序のアニメーション用
    @State private var showTitle = false
    @State private var showOneBlock = false
    @State private var showFiveBlock = false
    @State private var showArrow = false
    
    // 🌟 珠の動きアニメーション用
    @State private var lowerBeadCount = 1 // 何個の珠を動かすか（1〜4）
    @State private var isPushingUp = false // ★ 親指で「上に押し上げている」状態か
    @State private var isPushingFiveDown = false // ★ 人差し指で「下に下ろしている」状態か
    
    // 🌟 1.2秒ごとに「下げる→上げる」のアクションを繰り返す
    let timer = Timer.publish(every: 1.2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            VStack(spacing: h * 0.03) {
                Spacer()
                
                // ① タイトル
                Text("How to make 1~5")
                    .font(.custom("Papyrus", size: w * 0.08))
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : -20)
                
                // ② 「1〜4」のブロック（下から上へ弾く！）
                HStack(spacing: w * 0.05) {
                    ZStack {
                        Image("frame_t") // フレーム
                            .resizable()
                            .scaledToFit()
                            .frame(width: w * 0.5)
                        
                        // 【固定】上珠（5の珠）
                        Image("key")
                            .resizable()
                            .scaledToFit()
                            .frame(width: w * 0.09)
                            .offset(x: w * 0.085, y: -w * 0.15)
                        
                        // 【動く】下珠4つ
                        ForEach(0..<4, id: \.self) { index in
                            let isTarget = index < lowerBeadCount
                            Image("key")
                                .resizable()
                                .scaledToFit()
                                .frame(width: w * 0.09)
                                // ★ 親指が押し上げている(isPushingUp)時だけ上に動く！
                                .offset(x: w * 0.085, y: lowerBeadOffset(index: index, isPushing: isPushingUp, isTarget: isTarget, w: w))
                        }
                        
                        Image("one") // 親指
                            .resizable()
                            .scaledToFit()
                            .frame(width: w * 0.3)
                            // ★ 珠と一緒に下から上へ動く！
                            .offset(x: w * 0.15, y: thumbOffset(count: lowerBeadCount, isPushing: isPushingUp, w: w))
                    }
                    .frame(height: w * 0.4)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("This is \(numberWord(lowerBeadCount)).")
                            .font(.custom("Papyrus", size: w * 0.06))
                            .contentTransition(.numericText())
                            .animation(.default, value: lowerBeadCount)
                        
//                        Text("2, 3, and 4 are\nthe same way.")
//                            .font(.custom("Papyrus", size: w * 0.04))
//                            .foregroundColor(.gray)
                    }
                    .frame(width: w * 0.4, alignment: .leading)
                }
                .opacity(showOneBlock ? 1 : 0)
                .offset(y: showOneBlock ? 0 : -20)
                
                // ③ 「5」のブロック（上から下へ弾く！）
                HStack(spacing: w * 0.05) {
                    ZStack {
                        Image("frame_t") // フレーム
                            .resizable()
                            .scaledToFit()
                            .frame(width: w * 0.5)
                        
                        // 【動く】上珠（5の珠）
                        Image("key")
                            .resizable()
                            .scaledToFit()
                            .frame(width: w * 0.09)
                            // ★ isPushingFiveDownの時だけ下がる
                            .offset(x: w * 0.085, y: isPushingFiveDown ? -w * 0.12 : -w * 0.15)
                        
                        // 【固定】下珠4つ
                        ForEach(0..<4, id: \.self) { index in
                            Image("key")
                                .resizable()
                                .scaledToFit()
                                .frame(width: w * 0.09)
                                .offset(x: w * 0.085, y: lowerBeadOffset(index: index, isPushing: false, isTarget: false, w: w))
                        }
                        
                        Image("five") // 人差し指
                            .resizable()
                            .scaledToFit()
                            .frame(width: w * 0.3)
                            // ★ 5の珠の「上」に添えて、一緒に下へ動く！
                            .offset(x: w * 0.15, y: isPushingFiveDown ? -w * 0.05 : -w * 0.08)
                    }
                    .frame(height: w * 0.4)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("This is five.")
                            .font(.custom("Papyrus", size: w * 0.06))
                    }
                    .frame(width: w * 0.4, alignment: .leading)
                }
                .opacity(showFiveBlock ? 1 : 0)
                .offset(y: showFiveBlock ? 0 : -20)
                
                Spacer()
                
                if showNextArrow {
                    VStack {
                        
                        Image(systemName: "arrow.down")
                            .font(.system(size: w * 0.03))
                            // 矢印だけ「ふわふわ」上下に動かして誘導する
                            .offset(y: showArrow ? 2.5 : 0)
                            .animation(.easeInOut(duration: 0.6).repeatForever(), value: showArrow)
                    }
                    .opacity(showArrow ? 1 : 0)
                } else {
                    Spacer().frame(height: h * 0.1)
                }
            }
            .frame(width: w, height: h)
            .onAppear {
                triggerAnimations()
            }
            // 🌟 ストローク（弾く動き）のアニメーション！
            .onReceive(timer) { _ in
                guard showOneBlock else { return }
                
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    if isPushingUp {
                        // ① 弾き終わったら、手を定位置（下）に戻しつつ、次の数へセット
                        isPushingUp = false
                        isPushingFiveDown = false
                        lowerBeadCount = lowerBeadCount < 4 ? lowerBeadCount + 1 : 1
                    } else {
                        // ② 親指で下から上へグッと押し上げる！ / 5だまを下ろす！
                        isPushingUp = true
                        isPushingFiveDown = true
                    }
                }
            }
        }
    }
    
    // --- 🌟 表示順序のアニメーション ---
    private func triggerAnimations() {
        guard !showTitle else { return }
        Task {
            withAnimation(.easeOut(duration: 0.4)) { showTitle = true }
            try await Task.sleep(nanoseconds: 200_000_000)
            withAnimation(.easeOut(duration: 0.4)) { showOneBlock = true }
            try await Task.sleep(nanoseconds: 300_000_000)
            withAnimation(.easeOut(duration: 0.4)) { showFiveBlock = true }
            try await Task.sleep(nanoseconds: 300_000_000)
            withAnimation(.easeOut(duration: 0.4)) { showArrow = true }
        }
    }
    
    // --- 🌟 位置と文字の計算用関数 ---
    private func numberWord(_ num: Int) -> String {
        switch num {
        case 1: return "one"
        case 2: return "two"
        case 3: return "three"
        case 4: return "four"
        default: return "one"
        }
    }
    
    private func lowerBeadOffset(index: Int, isPushing: Bool, isTarget: Bool, w: CGFloat) -> CGFloat {
        let baseY = w * 0.01       // 一番上の下珠の待機位置
        let spacing = w * 0.05    // 珠同士の隙間
        let activeMove = -w * 0.07 // 押し上げる距離
        
        let positionY = baseY + (CGFloat(index) * spacing)
        // ターゲットの珠であり、かつ「押し上げている瞬間(isPushing)」だけ上に動く
        return positionY + (isTarget && isPushing ? activeMove : 0)
    }
    
    private func thumbOffset(count: Int, isPushing: Bool, w: CGFloat) -> CGFloat {
        // 対象となる一番下の珠（count - 1）の座標を取得
        let targetBeadY = lowerBeadOffset(index: count - 1, isPushing: isPushing, isTarget: true, w: w)
        // 親指は常にその珠の「少し下」に添える
        return targetBeadY + w * 0.05
    }
}
