//
//  BattleBarComponent.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/31.
//
import SwiftUI
struct BattleBarComponent: View {
    var value: Double
    var isGhost: Bool
    var body: some View {
        VStack(spacing: 4) {
            Text(isGhost ? "VS GHOST" : "SOLO MODE").font(.caption).bold()
            ZStack(alignment: .leading) {
                Capsule().fill(Color.gray.opacity(0.2))
                Capsule().fill(value < 0.3 ? .red : (value > 0.7 ? .blue : .green))
                    .frame(width: 300 * CGFloat(value))
            }.frame(width: 300, height: 25)
        }
    }
}
