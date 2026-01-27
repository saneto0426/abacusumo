//
//  ModeSelectView.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/08.
//

import SwiftUI

import SwiftUI

struct ModeSelectView: View {
    let isGhostMode: Bool
    var onSelect: (GameMode) -> Void
    var onBack: () -> Void

    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    // ★ 書道・明朝体風のフォント指定ですわ
    private func calligraphyFont(size: CGFloat) -> Font {
        return .custom("Papyrus", size: size)
    }

    var body: some View {
        ZStack {
            // --- 背景レイヤー ---
            Image(isGhostMode ? "n_select_screen" : "o_select_screen")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .clipped()
                .ignoresSafeArea()

            // --- UIレイヤー (ボタン以外) ---
            VStack(spacing: isPad ? 40 : 25) {
                // タイトル
                Text( " SELECT MODE ")
                    .font(.custom("Papyrus", size: isPad ? 44 : 26))
                    .fontWeight(.black)
                    .foregroundColor( .white )
                    .padding(.top, isPad ? 60 : 40)

                Spacer()

                // 各種目の選択ボタン
                VStack(spacing: isPad ? 30 : 15) {
                    ForEach(GameMode.allCases, id: \.self) { mode in
                        Button(action: { onSelect(mode) }) {
                            ZStack {
                                Image("option")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: isPad ? 450 : 280)
                                
                                // モード名
                                Text(modeName(mode))
                                    .font(calligraphyFont(size: isPad ? 28 : 20))
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                    .offset(y: -2)
                            }
                        }
                    }
                }

                Spacer()
                
                // ★以前ここにあった戻るボタンは削除しました
            }
        }
        // ★ GameViewと同じOverlay方式で戻るボタンを配置
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
            .padding(.top, isPad ? 40 : 50) // GameViewのパディングに合わせました
            .padding(.leading, 20)
        }
    }

    // ★ モード名を英語に変換しますわ
    func modeName(_ mode: GameMode) -> String {
        switch mode {
        case .addition: return "ADDITION"
        case .multiplication: return "MULTIPLICATION"
        case .division: return "DIVISION"
        }
    }
}
