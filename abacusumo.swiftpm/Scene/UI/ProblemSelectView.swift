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

            // 2. メインコンテンツ
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let baseW = min(w, h)

                ZStack {
                    VStack(spacing: h * 0.02) {
                        
                        // --- 固定されるヘッダー部分 ---
                        ZStack {
                            Image("button")
                                .resizable()
                                .frame(width: baseW * 0.5, height: baseW * 0.15)
                            
                            Text("SELECT LEVEL")
                                .font(.custom("Papyrus", size: baseW * 0.045))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .offset(y: baseW * 0.01)
                        }
                        .padding(.top, h * 0.02)
                        
                        // --- スクロールする問題選択ボタン部分 ---
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: baseW * 0.04) {
                                ForEach(1...4, id: \.self) { d in
                                    levelButton(label: "\(d) DIGITS (5 NUMS)", baseW: baseW) {
                                        onSelect(LevelConfig(mode: .addition, digits: d, count: 5))
                                    }
                                }
                            }
                            .padding(.bottom, h * 0.1)
                            .padding(.top, baseW * 0.02)
                        }
                    }
                    
                    // 【前面の枠フレーム】
                    Image("backFrame")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .clipped()
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
            }
        }
        // ★修正ポイント：ここの戻るボタンから `tap` 音を削除しました！
        // （ContentView側で backSound が鳴るため）
        .overlay(alignment: .topLeading) {
            Button(action: onBack) {
                Image("back")
                    .resizable().scaledToFit()
                    .frame(width: isPad ? 45 : 30)
                    .foregroundColor(.white)
            }
            .padding(.top, isPad ? 40 : 50)
            .padding(.leading, 20)
        }
    }

    // 選択肢のボタン
    func levelButton(label: String, baseW: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: {
            SoundManager.instance.playSound(name: "tap") // ★こっちのレベル選択の音は残しています
            action()
        }) {
            ZStack {
                Image("option")
                    .resizable()
                    .scaledToFit()
                    .frame(width: baseW * 0.5)
                
                Text(label)
                    .font(.custom("Papyrus", size: baseW * 0.03))
                    .fontWeight(.black)
                    .foregroundColor(.black)
                    .offset(y: -baseW * 0.005)
            }
        }
    }
}
