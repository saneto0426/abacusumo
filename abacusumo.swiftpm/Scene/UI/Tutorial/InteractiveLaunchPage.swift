//
//  Untitled.swift
//  Sum-o
//
//  Created by 🐣 on 2026/02/25.
//
import SwiftUI

struct InteractiveLaunchPage: View {
    @Binding var showInteractiveTutorial: Bool
    
    // アニメーション用
    @State private var showTitle = false
    @State private var showText = false
    @State private var showButton = false
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            VStack(spacing: h * 0.05) {
                Spacer()
                
                Text("Let's Try It!")
                    .font(.custom("Papyrus", size: w * 0.08))
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : -20)
                
                Text("Experience the real game controls\nin a guided tutorial.")
                    .font(.custom("Papyrus", size: w * 0.05))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .opacity(showText ? 1 : 0)
                    .offset(y: showText ? 0 : -20)
                
                // 🌟 体験チュートリアル起動ボタン
                Button(action: {
                    showInteractiveTutorial = true
                }) {
                    Text("Start Tutorial")
                        .font(.custom("Papyrus", size: w * 0.06))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.vertical, 15)
                        .padding(.horizontal, 40)
                        .background(
                            Image("button")
                                .resizable()
                                .frame(width: w * 0.7, height: w * 0.25)
                                // もし画像の縦横比が崩れて変に伸びるのが嫌な場合は、
                                // ここの下に .scaledToFill() を追加してみてね！
                        )
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                }
                .opacity(showButton ? 1 : 0)
                .offset(y: showButton ? 0 : -20)
                .padding(.top, 20)
                
                Spacer()
            }
            .frame(width: w, height: h)
            .onAppear {
                triggerAnimations()
            }
        }
    }
    
    private func triggerAnimations() {
        guard !showTitle else { return }
        Task {
            withAnimation(.easeOut(duration: 0.4)) { showTitle = true }
            try await Task.sleep(nanoseconds: 200_000_000)
            withAnimation(.easeOut(duration: 0.4)) { showText = true }
            try await Task.sleep(nanoseconds: 300_000_000)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { showButton = true }
        }
    }
}
