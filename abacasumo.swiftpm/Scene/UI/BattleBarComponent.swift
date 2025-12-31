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
            Text(isGhost ? "VS GHOST" : "SOLO MODE")
                .font(.caption).bold().foregroundColor(.secondary)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.gray.opacity(0.2))
                    Capsule()
                        .fill(value < 0.3 ? Color.red : (value > 0.7 ? Color.blue : Color.green))
                        .frame(width: geo.size.width * CGFloat(value))
                        .animation(.linear(duration: 0.1), value: value)
                }
            }
            .frame(height: 25).padding(.horizontal)
        }
    }
}
