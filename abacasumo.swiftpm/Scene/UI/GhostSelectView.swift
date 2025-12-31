//
//  GhostSelectView.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/08.
//

import SwiftUI

struct GhostSelectView: View {
    @ObservedObject var ghostManager: GhostManager
    let mode: GameMode
    var onSelect: (LevelConfig, GhostRecord) -> Void
    var onBack: () -> Void

    var body: some View {
        VStack {
            Text("\(mode.rawValue)のゴースト選択").font(.headline).padding()
            
            let filteredRecords = ghostManager.records.filter { $0.mode == mode }
            
            if filteredRecords.isEmpty {
                Text("まだ記録がありません。練習モードで保存してください。").padding()
                Spacer()
            } else {
                List(filteredRecords) { record in
                    Button(action: {
                        // 記録からConfigを復元（簡易実装）
                        let config = recoverConfig(from: record)
                        onSelect(config, record)
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(record.configLabel).bold()
                                Text(record.date, style: .date).font(.caption)
                            }
                            Spacer()
                            Text("タイム計: \(String(format: "%.1f", record.solveIntervals.reduce(0,+)))s")
                        }
                    }
                }
            }
            Button("戻る", action: onBack).padding()
        }
    }

    func recoverConfig(from record: GhostRecord) -> LevelConfig {
        // ラベル("3x2"など)から数字をパースしてConfigを再生成
        let digits = record.configLabel.compactMap { Int(String($0)) }
        return LevelConfig(mode: mode, digits: digits.first ?? 1, digitsRight: digits.last ?? 1)
    }
}
