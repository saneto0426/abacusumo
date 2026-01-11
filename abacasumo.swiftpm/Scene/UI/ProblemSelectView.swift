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

    // デバイス判定ですわ
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        ZStack {
            // 1. 【背景】o_select_screen を全画面に配置しますわ
            Image("o_select_screen")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .clipped()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // ヘッダー（英語表記）
                Text("SELECT \(mode.rawValue.uppercased()) LEVEL")
                    .font(.system(size: isPad ? 40 : 24, weight: .black, design: .serif))
                    .foregroundColor(.black)
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

                // 戻るボタン
                Button(action: onBack) {
                    ZStack {
                        Image("button") // ここは他と合わせてbutton画像を使いますわ
                            .resizable()
                            .frame(width: isPad ? 200 : 140, height: isPad ? 80 : 55)
                        Text("BACK")
                            .font(.system(size: isPad ? 24 : 18, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
                .padding(.bottom, isPad ? 60 : 30)
            }
        }
    }

    // ★ 選択肢のボタン（背景をoption画像にしますわ）
    func levelButton(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Image("option")
                    .resizable()
                    .scaledToFit()
                    .frame(width: isPad ? 450 : 280) // 画面サイズに合わせて調整
                
                Text(label)
                    .font(.system(size: isPad ? 32 : 20, weight: .black, design: .monospaced))
                    .foregroundColor(.black)
                    .offset(y: -2) // 重心の微調整
            }
        }
    }
}
