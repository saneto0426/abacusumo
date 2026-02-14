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
                        ForEach(1...4, id: \.self) { d in
                            levelButton(label: "\(d) DIGITS (5 NUMS)") {
                                // modeは .addition で固定！
                                onSelect(LevelConfig(mode: .addition, digits: d, count: 5))
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
