//
//  NameInputView.swift.swift
//  Sum-o
//
//  Created by 🐣 on 2026/01/27.
//

import SwiftUI

struct NameInputView: View {
    @Binding var inputName: String
    var onSave: () -> Void
    var onCancel: () -> Void

    // デバイス判定
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let baseW = min(w, h)
            
            ZStack {
      
                
                // 2. メインコンテンツ
                ZStack {
                    
                    Image("backscreen_t")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: w, height: h)
                        .clipped()
                        .ignoresSafeArea()
                    
                    VStack(spacing: baseW * 0.08) {
                        
                        // タイトル部分
                        VStack(spacing: baseW * 0.02) {
                            Text("VICTORY!")
                                .font(.custom("Papyrus", size: baseW * 0.12))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            Text("Enter your name to claim your glory")
                                .font(.custom("Papyrus", size: baseW * 0.04))
                                .fontWeight(.bold)
                                .foregroundColor(.black.opacity(0.7))
                        }
                        
                        // イラスト
                        Image("ghost")
                            .resizable()
                            .scaledToFit()
                            .frame(height: baseW * 0.25)
                        
                        // 入力フィールド
                        TextField("Player Name", text: $inputName)
                            // ★ 入力文字も Papyrus！
                            .font(.custom("Papyrus", size: baseW * 0.05))
                            .padding(baseW * 0.03)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .foregroundColor(.black)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black.opacity(0.5), lineWidth: 2)
                            )
                            .frame(width: baseW * 0.65)
                            .multilineTextAlignment(.center)
                        
                        // 登録ボタン
                        Button(action: {
                            // ★追加：登録ボタンを押した時に和太鼓を鳴らす！
                            SoundManager.instance.playSound(name: "wadaiko", ext: "mp3")
                            onSave()
                        }) {
                            ZStack {
                                Image("option")
                                    .resizable()
                                    .frame(width: baseW * 0.5, height: baseW * 0.15)
                                
                                Text("REGISTER")
                            
                                    .font(.custom("Papyrus", size: baseW * 0.05))
                                    .fontWeight(.black)
                                    .foregroundColor(.black)
                            }
                        }
                        .disabled(inputName.isEmpty)
                        .opacity(inputName.isEmpty ? 0.5 : 1.0)
                    }
                }
            }
            
            .overlay(alignment: .topLeading) {
                Button(action: {
                    // ★追加：キャンセルして戻る時も専用の音を鳴らす
                    SoundManager.instance.playSound(name: "backSound", ext: "mp3")
                    onCancel()
                }) {
                    Image("back")
                        .resizable().scaledToFit()
                        .frame(width: isPad ? 45 : 30)
                     
                        .foregroundColor(.black.opacity(0.8))
                }
                .padding(.top, isPad ? 40 : 50)
                .padding(.leading, 20)
            }
        }
    }
}
