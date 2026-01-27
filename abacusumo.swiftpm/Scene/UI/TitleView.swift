//
//  TitleView.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/31.
//

import SwiftUI

struct TitleView: View {
    var onStart: (GameMode) -> Void
    var onGhostMode: () -> Void

    // ゴーストの位置を管理する変数
    @State private var ghostOffsetX: CGFloat = 0
    @State private var ghostOffsetY: CGFloat = 0
    
    // 3秒ごとに位置を更新するタイマー
    let ghostTimer = Timer.publish(every: 3.0, on: .main, in: .common).autoconnect()
    
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    var body: some View {
        ZStack {
            // --- 1. 背景 ---
            Image("title_screen")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .clipped()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // --- 2. タイトルロゴ ---
                Image("title_logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: isPad ? 650 : 380)
                    .padding(.bottom, isPad ? 20 : 10)

                // --- 3. ふよふよゴースト（位置をランダムに！） ---
                ZStack {
                    Image("ghost")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: isPad ? 180 : 120)
                        // 位置だけを指定します。アニメーションの指示はここには書きませんわ
                        .offset(x: ghostOffsetX, y: ghostOffsetY)
                        .onAppear {
                            moveGhostRandomly() // 最初の一歩
                        }
                        .onReceive(ghostTimer) { _ in
                            moveGhostRandomly() // 定期的な移動
                        }
                }
                .frame(height: isPad ? 150 : 100)

                Spacer()

                // --- 4. 前のスタイルに戻したボタン群 ---
                VStack(spacing: isPad ? 40 : 20) {
                    // 一人稽古（SOLO TRAINING）
                    Button(action: { onStart(.addition) }) {
                        ZStack {
                            Image("button").resizable()
                                .frame(width: isPad ? 450 : 300, height: isPad ? 90 : 60)
                            Text("SOLO TRAINING")
                                .font(.custom("Papyrus", size: isPad ? 36 : 24))
                                .foregroundColor(.black)
                        }
                    }
                    
                    // ゴースト対戦（GHOST MATCH）
                    Button(action: { onGhostMode() }) {
                        ZStack {
                            Image("button").resizable()
                                .frame(width: isPad ? 450 : 300, height: isPad ? 90 : 60)
                            Text("GHOST MATCH")
                                .font(.custom("Papyrus", size: isPad ? 36 : 24))
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(.bottom, isPad ? 100 : 60)
            }
        }
    }

    // ★ ここが今回のポイント！明示的なアニメーション命令ですわ
    private func moveGhostRandomly() {
        let rangeX: CGFloat = isPad ? 80 : 50
        let rangeY: CGFloat = isPad ? 50 : 30

        // 「今から値を書き換えるから、3秒かけてアニメーションしてね！」と命じます
        withAnimation(.easeInOut(duration: 3.0)) {
            ghostOffsetX = CGFloat.random(in: -rangeX...rangeX)
            ghostOffsetY = CGFloat.random(in: -rangeY...rangeY)
        }
    }
}
