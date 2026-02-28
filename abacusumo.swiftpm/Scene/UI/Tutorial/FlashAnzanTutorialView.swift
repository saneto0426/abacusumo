//
//  FlashAnzanTutorialView.swift
//  Sum-o
//
//  Created by 🐣 on 2026/02/23.
//
import SwiftUI

// --- 2. フラッシュ暗算チュートリアル（Flash Anzan） ---
struct FlashAnzanTutorialView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // 1ページ目（フラッシュ暗算のルール説明）
                FlashAnzanPage(showNextArrow: true) // 次のページがあるなら true にしてね
                    .containerRelativeFrame(.vertical)
                
                FlashAnzanExplanationPage(showNextArrow: false) // ★ ここが最後なので false
                                    .containerRelativeFrame(.vertical)
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
    }
}


struct FlashAnzanPage: View {
    let showNextArrow: Bool
    
    // 表示順序のアニメーション用
    @State private var showTitle = false
    @State private var showContent = false
    @State private var showArrow = false
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    
 
    let numbers = [1, 2, 3, 4, 5]
    @State private var currentIndex = 0

    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            VStack(spacing: h * 0.01) {
                Spacer()
                
                // ① タイトル
                Text("What's Flash Anzan?")
                    .font(.custom("Papyrus", size: w * 0.08))
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : -20)
                
                VStack(spacing: w * 0.01) {
                
                    HStack(spacing: w * 0.005) {
                       
                        ZStack {
                            Image("board")
                                .resizable()
                                .scaledToFit()
                                .frame(width: w * 0.4)
                            
                          
                            if currentIndex < numbers.count {
                                Text("\(numbers[currentIndex])")
                                    .font(.custom("Papyrus", size: w * 0.15))
                                    .offset(y: w * 0.01)
                                    .contentTransition(.numericText())
                                    .animation(.default, value: currentIndex)
                            }
                        }
                        ZStack {
                          
                           Image("bubble")
                                .resizable()
                                .scaledToFit()
                                .frame(width: w * 0.5)
                            
       
                            Text(currentEquation)
                               
                                .font(.custom("Papyrus", size: w * (isPad ? 0.04 : 0.06)))
                                .minimumScaleFactor(0.3)
                                .lineLimit(1) // 1行に収める
                             
                                .frame(width: w * (isPad ? 0.18 : 0.25))
                                
                                .animation(.none, value: currentEquation)
                                .offset(y: w * -0.02)

                        }
                        .offset(y: w * 0.1)
                        
                       
                    }
                    Image("frog_head")
                        .resizable()
                        .scaledToFit()
                        .frame(width: w * 0.7)
        
//                    ZStack {
//                        // 吹き出し風の枠（画像があればImageに差し替えてね）
//                       Image("bubble")
//                            .resizable()
//                            .rotationEffect(.degrees(180))
//                            .frame(width: w * 0.8, height: w * 0.2)
//                        
//                        // 動的に変わる計算式
//                        Text(currentEquation)
//                            .font(.custom("Papyrus", size: w * 0.06))
//                            .animation(.none) // 文字のチラつき防止
//                    }
                    
               
                    Text("Numbers appear for a moment.\nAdd them up in your head!")
                        .font(.custom("Papyrus", size: w * 0.05))
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : -20)
                
                Spacer()
                
         
                if showNextArrow {
                    VStack {
                        Text("slide to next")
                            .font(.custom("Papyrus", size: w * 0.04))
                        Image(systemName: "arrow.down")
                            .font(.system(size: w * 0.08))
                            .offset(y: showArrow ? 0 : -10)
                            .animation(.easeInOut(duration: 0.8).repeatForever(), value: showArrow)
                    }
                    .opacity(showArrow ? 1 : 0)
                    .padding(.bottom, h * 0.05)
                } else {
                    Spacer().frame(height: h * 0.1)
                }
            }
            .frame(width: w, height: h)
            .onAppear {
                triggerAnimations()
            }
 
            .onReceive(timer) { _ in
                guard showContent else { return }
                
                
                if currentIndex > numbers.count {
                    currentIndex = 0 // リセット
                } else {
                    currentIndex += 1
                }
            }
        }
    }
    
    
    private var currentEquation: String {
        // まだ始まっていない時
        if currentIndex == 0 {
            return "\(numbers[0])"
        }
        // 計算途中の時
        else if currentIndex < numbers.count {
            let visibleNumbers = numbers[0...currentIndex]
            return visibleNumbers.map { "\($0)" }.joined(separator: " + ")
        }
        // 最後（合計を表示）の時
        else {
            let sum = numbers.reduce(0, +)
            let allNumbers = numbers.map { "\($0)" }.joined(separator: " + ")
            return "\(allNumbers) = \(sum)"
        }
    }

    private func triggerAnimations() {
        guard !showTitle else { return }
        Task {
            withAnimation(.easeOut(duration: 0.4)) { showTitle = true }
            try await Task.sleep(nanoseconds: 200_000_000)
            withAnimation(.easeOut(duration: 0.4)) { showContent = true }
            try await Task.sleep(nanoseconds: 300_000_000)
            withAnimation(.easeOut(duration: 0.4)) { showArrow = true }
        }
    }
}
// Flash Anzanの説明ページ（2ページ目）
struct FlashAnzanExplanationPage: View {
    let showNextArrow: Bool
    
    // アニメーション用
    @State private var showText1 = false
    @State private var showText2 = false
    @State private var showText3 = false
    @State private var showImage = false
    @State private var showArrow = false
    
    var body: some View {
        VStack(spacing: 40) { // 各段落の隙間
            Spacer()
            
            // 1段落目
            Text("Imagine an abacus in your head\nand move the beads to calculate.")
                .font(.custom("Papyrus", size: 50))
                .multilineTextAlignment(.center)
                .opacity(showText1 ? 1 : 0)
                .offset(y: showText1 ? 0 : -20)
            
            // 2段落目
            Text("It's great for brain training\nand everyday math like shopping!")
                .font(.custom("Papyrus", size: 50))
                .multilineTextAlignment(.center)
                .opacity(showText2 ? 1 : 0)
                .offset(y: showText2 ? 0 : -20)
            
            // 3段落目
            Text("This app is designed based on\nthe concept of Flash Anzan.")
                .font(.custom("Papyrus", size: 50))
                .multilineTextAlignment(.center)
                .opacity(showText3 ? 1 : 0)
                .offset(y: showText3 ? 0 : -20)
            
      
            Image("rabbit")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 120)
                .opacity(showImage ? 1 : 0)
                .offset(y: showImage ? 0 : -20)
                .padding(.top, 10)
            
            Spacer()
            
            // 矢印（次がある場合）
            if showNextArrow {
                VStack {
                    Text("slide to next")
                        .font(.custom("Papyrus", size: 16))
                    Image(systemName: "arrow.down")
                        .font(.system(size: 30))
                        .offset(y: showArrow ? 0 : -10)
                        .animation(.easeInOut(duration: 0.8).repeatForever(), value: showArrow)
                }
                .opacity(showArrow ? 1 : 0)
                .padding(.bottom, 50)
            } else {
                Spacer().frame(height: 80)
            }
        }
        .padding(.horizontal, 20)
        .onAppear {
            triggerAnimations()
        }
    }
    
    // ---  順番に表示するアニメーション ---
    private func triggerAnimations() {
        guard !showText1 else { return }
        Task {
            withAnimation(.easeOut(duration: 0.4)) { showText1 = true }
            try await Task.sleep(nanoseconds: 300_000_000)
            
            withAnimation(.easeOut(duration: 0.4)) { showText2 = true }
            try await Task.sleep(nanoseconds: 300_000_000)
            
            withAnimation(.easeOut(duration: 0.4)) { showText3 = true }
            try await Task.sleep(nanoseconds: 300_000_000)
            
            withAnimation(.easeOut(duration: 0.4)) { showImage = true }
            try await Task.sleep(nanoseconds: 300_000_000)
            
            withAnimation(.easeOut(duration: 0.4)) { showArrow = true }
        }
    }
}
