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
    
    // アニメーション用の状態管理
    @State private var selectedMenu: String? = nil
    @State private var fadeOutOthers = false
    @State private var flyUpOffset: CGFloat = 0
    @State private var showInside = false
    @State private var insideOffset: CGFloat = -2000
    @State private var showInteractiveTutorial = false
    
    // 巻物のリスト
    let menus = ["Ume", "Take", "Matsu"]
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            // 💡 11インチiPadでもはみ出さないように横幅を制限（画面幅の80%かつ最大800px）
            let scrollWidth = min(w * 0.8, 800)
            
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
                    VStack(spacing: h * 0.05) {
                        // 💡 menus を直接参照し、確実に String として扱う
                        ForEach(menus, id: \.self) { imageName in
                            let isSelected = (selectedMenu == imageName)
                            
                            Button(action: {
                                // ★追加：モードを選んだ時に和太鼓を鳴らす！
                                SoundManager.instance.playSound(name: "wadaikoHuchi", ext: "mp3")
                                startAnimation(for: imageName, screenHeight: h)
                            }) {
                                // 💡 下で定義している新しい ScrollImage を呼び出す
                                ScrollImage(imageName: imageName, targetWidth: scrollWidth)
                                    .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 8)
                            }
                            .disabled(selectedMenu != nil)
                            .opacity(fadeOutOthers && !isSelected ? 0 : 1)
                            .offset(y: isSelected ? flyUpOffset : 0)
                        }
                    }
                }
                
                // --- 3. チュートリアルの中身（開いた巻物） ---
                if showInside {
                    ZStack {
                        Image("makimono_middle")
                            .resizable()
                            .frame(width: w * 0.95, height: h * 0.9)
                            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 10)
                                    
                        ZStack {
                            if selectedMenu == "Ume" {
                                AbacusTutorialView()
                            } else if selectedMenu == "Take" {
                                FlashAnzanTutorialView()
                            } else if selectedMenu == "Matsu" {
                                HowToPlayView()
                            }
                        }
                        .frame(width: w * 0.85, height: h * 0.8)
                                        
                        // 閉じるボタン
                        // チュートリアルからメニューに戻る（閉じる）ボタン
                                                VStack {
                                                    HStack {
                                                        
                                                        Button(action: {
                                                            // ★追加：チュートリアルを閉じる（巻物を戻す）時にもページ音を鳴らす
                                                            SoundManager.instance.playSound(name: "backSound", ext: "mp3")
                                                            closeAnimation(screenHeight: h)
                                                        }) {
                                                            Image("back")
                                                                .resizable()
                                                                .frame(width: w * 0.05, height: w * 0.05)
                                                                .foregroundColor(.black.opacity(0.6))
                                                        }
                                                 
                                                        .padding(.leading, w * 0.05 + 10)
                                                        .padding(.top, h * 0.08 + 10)
                                                        
                                                        Spacer()
                                                    }
                                                    Spacer()
                                                }
                    }
                    .offset(y: insideOffset)
                    .zIndex(1)
                }
                
                // --- 4. 戻るボタン（左上） ---
                if !showInside {
                    VStack {
                        HStack {
                            Button(action: {
                                // ★追加：いつもの戻るボタンの音
                                SoundManager.instance.playSound(name: "backSound", ext: "mp3")
                                dismiss()
                            }) {
                                Image("back")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: isPad ? 45 : 18, height: isPad ? 45 : 18)
                                    .foregroundColor(.white)
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
    
    // --- アニメーション関数 ---
    private func startAnimation(for menu: String, screenHeight: CGFloat) {
        selectedMenu = menu
        Task {
            withAnimation(.easeOut(duration: 0.3)) { fadeOutOthers = true }
            try? await Task.sleep(nanoseconds: 300_000_000)
            
            withAnimation(.easeIn(duration: 0.4)) { flyUpOffset = -screenHeight }
            try? await Task.sleep(nanoseconds: 400_000_000)
            
            insideOffset = -screenHeight
            showInside = true
            
            // ★追加：巻物の中身が表示される（降りてくる）瞬間にページをめくる音を鳴らす！
            SoundManager.instance.playSound(name: "page", ext: "mp3")
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { insideOffset = 0 }
        }
    }
    
    private func closeAnimation(screenHeight: CGFloat) {
        Task {
            withAnimation(.easeIn(duration: 0.4)) { insideOffset = -screenHeight }
            try? await Task.sleep(nanoseconds: 400_000_000)
            
            showInside = false
            flyUpOffset = -screenHeight
            withAnimation(.easeOut(duration: 0.4)) { flyUpOffset = 0 }
            try? await Task.sleep(nanoseconds: 400_000_000)
            
            withAnimation(.easeIn(duration: 0.3)) { fadeOutOthers = false }
            try? await Task.sleep(nanoseconds: 300_000_000)
            selectedMenu = nil
        }
    }
}

// 💡 エラー回避のため、同じファイル内に定義
struct ScrollImage: View {
    let imageName: String
    let targetWidth: CGFloat
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: targetWidth)
    }
}
