//
//  ProblemSelectView.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/08.
//
import SwiftUI

struct ProblemSelectView: View {
    let mode: GameMode
    var onSelect: (LevelConfig) -> Void
    var onBack: () -> Void

    var body: some View {
        VStack {
            Text("\(mode.rawValue)の桁数選択").font(.title2).bold().padding()
            List {
                if mode == .addition {
                    ForEach(1...4, id: \.self) { d in
                        Button("\(d)桁 5口") {
                            onSelect(LevelConfig(mode: .addition, digits: d, count: 5))
                        }
                    }
                } else if mode == .multiplication {
                    // 文字列をIDにすることでエラーを回避
                    let options = ["1x1", "2x1", "2x2", "3x1", "3x2", "3x3"]
                    Section("掛け算") {
                        let options = ["1x1", "2x1", "2x2", "3x1", "3x2", "3x3"]
                        ForEach(options, id: \.self) { opt in
                            Button(opt) {
                                let parts = opt.split(separator: "x").map { Int($0)! }
                                onSelect(LevelConfig(mode: .multiplication, digits: parts[0], digitsRight: parts[1]))
                            }
                        }
                    }
                } else if mode == .division {
                    let options = ["2/1", "3/1", "3/2", "4/1", "4/2"]
                    Section("割り算") {
                        let options = ["2/1", "3/1", "3/2", "4/1", "4/2"]
                        ForEach(options, id: \.self) { opt in
                            Button(opt.replacingOccurrences(of: "/", with: "÷")) {
                                let parts = opt.split(separator: "/").map { Int($0)! }
                                onSelect(LevelConfig(mode: .division, digits: parts[0], digitsRight: parts[1]))
                            }
                        }
                    }
                }
            }
            Button("戻る", action: onBack).padding()
        }
    }
}
