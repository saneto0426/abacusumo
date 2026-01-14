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

    @State private var isAnimating = false
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    var body: some View {
        ZStack {
            // --- 1. 背景（画面一杯に） ---
            Image("title_screen") // もしくは "title_background"
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                // --- 2. ロゴとふよふよゴースト ---
                ZStack(alignment: .top) {
                    // ゴーストのアニメーション
                    Image("ghost")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: isPad ? 150 : 100)
                        .offset(y: isAnimating ? -25 : 15)
                        .animation(
                            Animation.easeInOut(duration: 2.5).repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                        .onAppear { isAnimating = true }
                        .offset(y: isPad ? -140 : -90)
                    
                    // タイトルロゴ
                    Image("title_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: isPad ? 650 : 380)
                }
                
                Spacer()

                // --- 3. 元のスタイルのボタン群 ---
                VStack(spacing: isPad ? 40 : 20) {
                    // 一人稽古（SOLO TRAINING）
                    Button(action: { onStart(.addition) }) { // デフォルトでみとり等
                        ZStack {
                            Image("key") // 元のボタン画像
                                .resizable()
                                .frame(width: isPad ? 450 : 300, height: isPad ? 90 : 60)
                            Text("SOLO TRAINING")
                                .font(.custom("Papyrus", size: isPad ? 36 : 24))
                                .foregroundColor(.black)
                        }
                    }
                    
                    // ゴースト対戦（GHOST MATCH）
                    Button(action: { onGhostMode() }) {
                        ZStack {
                            Image("key")
                                .resizable()
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
}
