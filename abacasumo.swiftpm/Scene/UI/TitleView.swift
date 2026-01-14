//
//  TitleView.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/31.
//

import SwiftUI

struct TitleView: View {
    var onStartSolo: () -> Void
    var onStartGhost: () -> Void

    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    var body: some View {
        ZStack {
            // 背景レイヤー
            Image("title_screen")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .clipped()

            // UIレイヤー（ボタン）
            VStack {
                Spacer()
                
                HStack(spacing: isPad ? 40 : 20) {
                    // 一人稽古ボタン
                    Button(action: onStartSolo) {
                        ZStack {
                            // ★ 背景を「option」画像に変更しましたわ！
                            Image("option")
                                .resizable()
                                .scaledToFit()
                                .frame(width: isPad ? 220 : 160) // 少し大きめに調整しましたわ
                            
                            Text("solo mode")
                                .font(.system(size: isPad ? 26 : 20, weight: .bold, design: .serif))
                                .foregroundColor(.black)
                                .offset(y: -2) // 画像の重心に合わせて微調整ですわ
                        }
                    }
                    
                    // 巡業対戦ボタン
                    Button(action: onStartGhost) {
                        ZStack {
                            // ★ こちらも「option」に変更ですわ
                            Image("option")
                                .resizable()
                                .scaledToFit()
                                .frame(width: isPad ? 220 : 160)
                            
                            Text("ghost mode")
                                .font(.system(size: isPad ? 26 : 20, weight: .bold, design: .serif))
                                .foregroundColor(.black)
                                .offset(y: -2)
                        }
                    }
                }
                .padding(.bottom, isPad ? 100 : 60)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}
