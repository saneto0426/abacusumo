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

    @State private var ghostOffsetX: CGFloat = 0
    @State private var ghostOffsetY: CGFloat = 0
    
    // チュートリアル画面への遷移管理
    @State private var isShowingTutorial = false

    let ghostTimer = Timer.publish(every: 3.0, on: .main, in: .common).autoconnect()
    
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    var body: some View {
        // 全体をNavigationStackで包む
        NavigationStack {
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

                    // --- 3. ふよふよゴースト ---
                    ZStack {
                        Image("ghost")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: isPad ? 180 : 120)
                            .offset(x: ghostOffsetX, y: ghostOffsetY)
                            .onAppear { moveGhostRandomly() }
                            .onReceive(ghostTimer) { _ in moveGhostRandomly() }
                    }
                    .frame(height: isPad ? 150 : 100)

                    Spacer()

                    // --- 4. ボタン群 ---
                    VStack(spacing: isPad ? 30 : 15) {
                        // SOLO TRAINING
                        Button(action: { onStart(.addition) }) {
                            MenuButtonView(title: "SOLO TRAINING", isPad: isPad)
                        }
                        
                        // GHOST MATCH
                        Button(action: { onGhostMode() }) {
                            MenuButtonView(title: "GHOST MATCH", isPad: isPad)
                        }

                        // ★ チュートリアルボタンを追加！
                        NavigationLink(destination: TutorialMenuView()) {
                            MenuButtonView(title: "TUTORIAL", isPad: isPad)
                        }
                    }
                    .padding(.bottom, isPad ? 100 : 60)
                }
            }
        }
    }

    private func moveGhostRandomly() {
        let rangeX: CGFloat = isPad ? 80 : 50
        let rangeY: CGFloat = isPad ? 50 : 30
        withAnimation(.easeInOut(duration: 3.0)) {
            ghostOffsetX = CGFloat.random(in: -rangeX...rangeX)
            ghostOffsetY = CGFloat.random(in: -rangeY...rangeY)
        }
    }
}

// ボタンの見た目を共通化（コードをスッキリさせるため）
struct MenuButtonView: View {
    let title: String
    let isPad: Bool
    
    var body: some View {
        ZStack {
            Image("button").resizable()
                .frame(width: isPad ? 450 : 300, height: isPad ? 90 : 60)
            Text(title)
                .font(.custom("Papyrus", size: isPad ? 36 : 24))
                .foregroundColor(.black)
        }
    }
}
