//
//  TutorialMenuView.swift
//  Sum-o
//
//  Created by 🐣 on 2026/02/23.
//

import SwiftUI

struct TutorialMenuView: View {
    @Environment(\.dismiss) var dismiss
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    
    // --- 🌟 アニメーション用の状態管理 ---
    @State private var selectedMenu: String? = nil
    @State private var fadeOutOthers = false
    @State private var flyUpOffset: CGFloat = 0
    @State private var showInside = false
    @State private var insideOffset: CGFloat = -2000 // 最初は画面のはるか上に待機
    
    @State private var showInteractiveTutorial = false
    
    // 巻物のリスト（画像名）
    let menus = ["Ume", "Take", "Matsu"]
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            let widthBase = w * (isPad ? 0.8 : 0.9)
            let heightBase = h * (isPad ? 0.5 : 0.8)
            let baseW = min(widthBase, heightBase)
            
            ZStack {
                // --- 1. 背景 ---
                Image("backscreen_t")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .clipped()
                    .ignoresSafeArea()

                
                // --- 2. 巻物ボタン群 ---
                if !showInside {
                    VStack(spacing: baseW * 0.05) {
                        ForEach(menus, id: \.self) { imageName in
                            let isSelected = selectedMenu == imageName
                            
                            Button(action: {
                                startAnimation(for: imageName, screenHeight: h)
                            }) {
                                ScrollImage(imageName: imageName, baseW: baseW, scale: 1.6)
                                    .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 8)
                            }
                            .disabled(selectedMenu != nil) // アニメーション中は連打禁止
                            .opacity(fadeOutOthers && !isSelected ? 0 : 1) // 選ばれてないものは透明に
                            .offset(y: isSelected ? flyUpOffset : 0) // 選ばれたものは上に飛ぶ
                        }
                    }
                }
                
                // --- 3. チュートリアルの中身（上から降ってくる） ---
                if showInside {
                    ZStack {
                        // ★ 第二の背景（開いた巻物の素材）
                        Image("makimono_middle") // ← ここを2番目の画像の名前に変更してね！
                        .resizable()
                        // 全画面ではなく、少し余白を残して「巻物」っぽさを出す
                        .frame(width: w * 0.95, height: h * 0.9)
                        // 影をつけると、さらに「手前に降りてきた感」が出るよ！
                        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 10)
                                    
                        // 巻物の中に収まるように、コンテンツエリアを少し小さめに確保
                        ZStack {
                            if selectedMenu == "Ume" {
                                AbacusTutorialView()
                            } else if selectedMenu == "Take" {
                                FlashAnzanTutorialView()
                                
                            } else if selectedMenu == "Matsu" {
                                HowToPlayView()
                            }
                        }
                        .frame(width: w * 0.85, height: h * 0.8) // 巻物の内側に収まるサイズ
                                        
                        // チュートリアルからメニューに戻る（閉じる）ボタン
                        VStack {
                            HStack {
                                Spacer()
                                Button(action: { closeAnimation(screenHeight: h) }) {
                                Image("back")
                                .resizable()
                                .frame(width: baseW * 0.08, height: baseW * 0.08)
                                .foregroundColor(.black.opacity(0.6))
                                }
                                                // 巻物の右上に配置されるように微調整
                                .padding(.trailing, w * 0.05 + 10)
                                .padding(.top, h * 0.05 + 10)
                            }
                            Spacer()
                        }
                    }
                    .offset(y: insideOffset)
                    .zIndex(1) // メニューより手前に表示
                }
                
                // --- 4. タイトル画面に戻るボタン（左上） ---
                if !showInside {
                    VStack {
                        HStack {
                            Button(action: { dismiss() }) {
                                Image("back")
                                    .resizable()
                                    .frame(width: baseW * 0.08, height: baseW * 0.08)
                                    .foregroundColor(.black.opacity(0.6))
                            }
                            .padding(.leading, 30)
                            .padding(.top, 20)
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
            .frame(width: w, height: h)
        }
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $showInteractiveTutorial) {
                    InteractiveTutorialView()
                }
    }
    
    // --- 🌟 アニメーションの魔法（非同期処理） ---
    private func startAnimation(for menu: String, screenHeight: CGFloat) {
        selectedMenu = menu
        
        Task {
            // ① 他の巻物をフワッと消す
            withAnimation(.easeOut(duration: 0.3)) {
                fadeOutOthers = true
            }
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3秒待つ
            
            // ② 選んだ巻物を上にシュン！と飛ばす
            withAnimation(.easeIn(duration: 0.4)) {
                flyUpOffset = -screenHeight
            }
            try await Task.sleep(nanoseconds: 400_000_000) // 0.4秒待つ
            
            // ③ 上からチュートリアルの中身（開いた巻物）をドスン！と降ろす
            insideOffset = -screenHeight // 画面外（上）にセット
            showInside = true
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                insideOffset = 0
            }
        }
    }
    
    private func closeAnimation(screenHeight: CGFloat) {
        Task {
            // ① 開いた巻物を上にシュン！と戻す
            withAnimation(.easeIn(duration: 0.4)) {
                insideOffset = -screenHeight
            }
            try await Task.sleep(nanoseconds: 400_000_000)
            
            showInside = false
            flyUpOffset = -screenHeight // 巻物（閉）はまだ上にある
            
            // ② 選んでいた巻物が上から戻ってくる
            withAnimation(.easeOut(duration: 0.4)) {
                flyUpOffset = 0
            }
            try await Task.sleep(nanoseconds: 400_000_000)
            
            // ③ 他の巻物をフワッと復活させる
            withAnimation(.easeIn(duration: 0.3)) {
                fadeOutOthers = false
            }
            try await Task.sleep(nanoseconds: 300_000_000)
            
            selectedMenu = nil // 状態リセット
        }
    }
}

// 画像だけを表示するシンプルなコンポーネント
struct ScrollImage: View {
    let imageName: String
    let baseW: CGFloat
    let scale: CGFloat
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: baseW * scale)
    }
}
