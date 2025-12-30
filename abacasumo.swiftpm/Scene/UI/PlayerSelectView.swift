//
//  TitleView.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/08.
//

import SwiftUI

struct TitleView: View {
    // 画面を切り替えるためのアクション（親から受け取る）
    var onSelectMode: (GameMode) -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Text("abacusmo")
                .font(.system(size: 40, weight: .black))
                .padding(.bottom, 50)
            
            VStack(spacing: 20) {
                modeButton(title: "Mental Arithmetic", mode: .addition, color: .green)
                modeButton(title: "Multiplication", mode: .multiplication, color: .orange)
                modeButton(title: "Division", mode: .division, color: .blue)
            }
            .padding(.horizontal, 40)
        }
    }
    
    // ボタンの共通パーツ
    func modeButton(title: String, mode: GameMode, color: Color) -> some View {
        Button(action: { onSelectMode(mode) }) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(15)
        }
    }
}
