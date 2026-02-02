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

    // デバイス判定
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        ZStack {
            // 1. 【背景】
            Image("o_select_screen")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .clipped()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // ヘッダー（Papyrusフォント）
                Text("SELECT LEVEL")
                    .font(.custom("Papyrus", size: isPad ? 44 : 26)) // Papyrusに変更
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, isPad ? 60 : 40)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: isPad ? 25 : 15) {
                        if mode == .addition {
                            ForEach(1...4, id: \.self) { d in
                                levelButton(label: "\(d) DIGITS (5 NUMS)") {
                                    onSelect(LevelConfig(mode: .addition, digits: d, count: 5))
                                }
                            }
                        } else if mode == .multiplication {
                            let options = ["1x1", "2x1", "2x2", "3x1", "3x2", "3x3"]
                            ForEach(options, id: \.self) { opt in
                                levelButton(label: opt) {
                                    let parts = opt.split(separator: "x").map { Int($0)! }
                                    onSelect(LevelConfig(mode: .multiplication, digits: parts[0], digitsRight: parts[1]))
                                }
                            }
                        } else if mode == .division {
                            let options = ["2/1", "3/1", "3/2", "4/1", "4/2"]
                            ForEach(options, id: \.self) { opt in
                                levelButton(label: opt.replacingOccurrences(of: "/", with: "÷")) {
                                    let parts = opt.split(separator: "/").map { Int($0)! }
                                    onSelect(LevelConfig(mode: .division, digits: parts[0], digitsRight: parts[1]))
                                }
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
                
                // ★以前ここにあった戻るボタンは削除しました（overlayに移動）
            }
        }
        // ★ GameViewと同じOverlay方式で戻るボタンを左上に配置
        .overlay(alignment: .topLeading) {
            Button(action: onBack) {
                ZStack {
                    Image("back") // 戻るアイコン
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: isPad ? 45 : 18, height: isPad ? 45 : 18)
                        .foregroundColor(.white)
                }
            }
            // GameViewと位置を合わせるためのパディング
            .padding(.top, isPad ? 40 : 50)
            .padding(.leading, 20)
        }
    }

    // 選択肢のボタン
    func levelButton(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Image("option")
                    .resizable()
                    .scaledToFit()
                    .frame(width: isPad ? 450 : 280)
                
                Text(label)
                    .font(.custom("Papyrus", size: isPad ? 34 : 22)) // Papyrusに変更
                    .fontWeight(.black)
                    .foregroundColor(.black)
                    .offset(y: -2)
            }
        }
    }
}
