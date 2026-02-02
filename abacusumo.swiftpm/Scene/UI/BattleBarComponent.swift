//
//  BattleBarComponent.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/31.
//
import SwiftUI

struct BattleBarComponent: View {
    var value: Double // 0.0 (左負け) 〜 1.0 (右勝ち)
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // バーの土台（透明でも良いですが、目安として）
                Capsule().fill(Color.black.opacity(0.1))
                    .frame(height: 10)
                
                // ★ 取り組み画像 (sumo_torikumi) ★
                // ゲージの値に合わせて左右にスライドしますわ！
                Image("sumo_torikumi")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .offset(x: geo.size.width * CGFloat(value - 0.5))
                    .animation(.interactiveSpring(), value: value)
            }
        }
        .frame(height: 80)
        .padding(.horizontal, 40)
    }
}
