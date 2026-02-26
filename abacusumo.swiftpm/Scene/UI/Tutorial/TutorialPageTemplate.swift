//
//  TutorialContentViews.swift
//  Sum-o
//
//  Created by 🐣 on 2026/02/23.
//

import SwiftUI



// --- 2. 各ページの中身と「すっすっす」アニメーション ---
struct TutorialPageTemplate1: View {
    let title: String
    let imageName: String
    let description: String
    let showNextArrow: Bool
    
    // アニメーション用の状態管理（最初は全部透明＆少し上に配置）
    @State private var showTitle = false
    @State private var showImage = false
    @State private var showText = false
    @State private var showArrow = false
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            VStack(spacing: h * 0.03) {
                Spacer()
                
                // ① タイトル
                Text(title)
                    .font(.custom("Papyrus", size: w * 0.08)) // 手書き風フォント
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : -20) // 上から下へ降りてくる
                
                // ② 画像
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: w * 0.8)
                    .opacity(showImage ? 1 : 0)
                    .offset(y: showImage ? 0 : -20)
                
                // ③ 説明テキスト
                Text(description)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.custom("Papyrus", size: w * 0.04))
                    .multilineTextAlignment(.center)
                    .opacity(showText ? 1 : 0)
                    .offset(y: showText ? 0 : -20)
                
                Spacer()
                
                // ④ 「次へ」の矢印（下向き）
                if showNextArrow {
                    VStack {
                        Text("slide to next")
                            .font(.custom("Papyrus", size: w * 0.04))
                        Image(systemName: "arrow.down")
                            .font(.system(size: w * 0.03))
                            // 矢印だけ「ふわふわ」上下に動かして誘導する
                            .offset(y: showArrow ? 2.5 : 0)
                            .animation(.easeInOut(duration: 0.6).repeatForever(), value: showArrow)
                    }
                    .opacity(showArrow ? 1 : 0)
                } else {
                    Spacer().frame(height: h * 0.1) // 矢印がない時のスペース
                }
            }
            .frame(width: w, height: h)
            .onAppear {
                triggerAnimations() // 画面に表示されたらアニメーション開始！
            }
        }
    }
    
    // --- 🌟 「すっすっす」と順番に出す魔法 ---
    private func triggerAnimations() {
        // すでに表示済みなら何もしない（ページをスクロールして戻った時の対策）
        guard !showTitle else { return }
        
        Task {
            // 0.2〜0.3秒ごとに次の要素を表示していく
            withAnimation(.easeOut(duration: 0.4)) { showTitle = true }
            try await Task.sleep(nanoseconds: 200_000_000)
            
            withAnimation(.easeOut(duration: 0.4)) { showImage = true }
            try await Task.sleep(nanoseconds: 200_000_000)
            
            withAnimation(.easeOut(duration: 0.4)) { showText = true }
            try await Task.sleep(nanoseconds: 300_000_000)
            
            withAnimation(.easeOut(duration: 0.4)) { showArrow = true }
        }
    }
}
