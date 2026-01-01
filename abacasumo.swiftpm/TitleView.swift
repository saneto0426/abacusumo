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

    // iPadかどうかを判定しますわ
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        // ★ 画面の底から天までを一つのキャンバスと定義します
        ZStack {
            // --- 背景レイヤー ---
            // 3000x4000の比率を保ちつつ、物理的な画面サイズいっぱいに広げます
            Image("title_screen")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .clipped()

            // --- UIレイヤー（ボタン） ---
            VStack {
                Spacer() // 上側を空けて、ボタンを下に寄せます
                
                HStack(spacing: isPad ? 40 : 20) {
                    // 一人稽古ボタン
                    Button(action: onStartSolo) {
                        ZStack {
                            Image("button")
                                .resizable()
                                .frame(width: isPad ? 200 : 150, height: isPad ? 80 : 60)
                            Text("一人稽古")
                                .font(.system(size: isPad ? 24 : 18, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                    
                    // 巡業対戦ボタン
                    Button(action: onStartGhost) {
                        ZStack {
                            Image("button")
                                .resizable()
                                .frame(width: isPad ? 200 : 150, height: isPad ? 80 : 60)
                            Text("巡業対戦")
                                .font(.system(size: isPad ? 24 : 18, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                }
                // iPadのホームインジケーター（下の棒）に被らないギリギリを攻めますわ
                .padding(.bottom, isPad ? 80 : 50)
            }
        }
        // ★ これが一番外側にかかっていることが重要ですわ！
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black) // 万が一の隙間も黒で埋めて違和感を消します
        .ignoresSafeArea(.all) // 全てのセーフエリアを無視して突き進みますわ
    }
}
