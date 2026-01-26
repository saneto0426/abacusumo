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

            // --- UIレイヤー ---
            VStack(spacing: isPad ? 40 : 25) {
                // タイトル：英語に変更 ＆ ゴーストモード時は白文字に
                Text( " SELECT MODE ")
                    .font(.custom("Papyrus", size: isPad ? 44 : 26))
                    .fontWeight(.black)
                    // ★ ゴーストモードなら白、一人稽古なら黒にしますわ
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
                                
                                // モード名も英語ですわ
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

                // 戻るボタン
                Button(action: onBack) {
                    ZStack {
                        
                        
                        Image("back") // 戻るアイコン
                            .resizable() // ★これを入れないとサイズ変更が効きませんの！
                            .aspectRatio(contentMode: .fit)
                            .frame(width: isPad ?  45 : 18, height: isPad ? 45 : 18) // ここで実際の大きさを指定
                            .foregroundColor(.white) // 元画像がテンプレートなら色が付きますわ
                    }
                }
                .offset(y: isPad ? -1095 : 35)
                .offset(x: isPad ? -367.5 : 35)
                
            }
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
