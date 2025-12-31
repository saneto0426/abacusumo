//
//  TitleView.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/31.
//

import SwiftUI

struct TitleView: View {
    // ContentViewから渡されるアクションを受け取る変数
    var onStartSolo: () -> Void
    var onStartGhost: () -> Void

    var body: some View {
        VStack(spacing: 40) {
            // 相撲風のタイトル
            Text("あばかすもう")
                .font(.system(size: 50, weight: .black, design: .serif))
                .foregroundColor(.primary)
            
            VStack(spacing: 20) {
                // 一人プレイボタン
                Button(action: onStartSolo) {
                    Text("一人稽古 (練習)")
                        .font(.title2).bold()
                        .frame(width: 280, height: 70)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                
                // ゴースト対戦ボタン
                Button(action: onStartGhost) {
                    Text("巡業 (ゴースト対戦)")
                        .font(.title2).bold()
                        .frame(width: 280, height: 70)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.05).edgesIgnoringSafeArea(.all))
    }
}
