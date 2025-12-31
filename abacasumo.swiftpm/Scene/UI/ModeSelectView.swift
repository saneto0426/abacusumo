//
//  ModeSelectView.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/08.
//

import SwiftUI

struct ModeSelectView: View {
    let isGhostMode: Bool
    var onSelect: (GameMode) -> Void
    var onBack: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Text(isGhostMode ? "対戦モード：種目選択" : "一人練習：種目選択")
                .font(.title).bold()

            ForEach(GameMode.allCases, id: \.self) { mode in
                Button(action: { onSelect(mode) }) {
                    Text(mode.rawValue)
                        .font(.title2).bold()
                        .frame(width: 200, height: 80)
                        .background(modeColor(mode))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
            }

            Button("戻る", action: onBack).padding()
        }
    }

    func modeColor(_ mode: GameMode) -> Color {
        switch mode {
        case .addition: return .blue
        case .multiplication: return .green
        case .division: return .orange
        }
    }
}
