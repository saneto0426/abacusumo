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

    // ★追加：選んだ「桁数」を一時的に記憶する変数
    @State private var selectedDigit: Int? = nil

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
                            
                            // ★変更：状態によってタイトルを切り替えるとおしゃれ！
                            Text(selectedDigit == nil ? "SELECT DIGITS" : "SELECT NUMS")
                                .font(.custom("Papyrus", size: baseW * 0.045))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .offset(y: baseW * 0.01)
                        }
                        .padding(.top, h * 0.02)
                        
                        // --- 問題選択ボタン部分 ---
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: baseW * 0.04) {
                                
                                if let d = selectedDigit {
                                    // 【ステップ2】桁数が選ばれている時は「口数」を表示
                                    let counts = [3, 5, 7]
                                    ForEach(counts, id: \.self) { c in
                                        levelButton(label: "\(c) NUMS", baseW: baseW) {
                                            // ここで最終決定！GameViewへ進む
                                            onSelect(LevelConfig(mode: .addition, digits: d, count: c))
                                        }
                                    }
                                } else {
                                    // 【ステップ1】まだ選ばれていない時は「桁数」を表示
                                    ForEach(1...4, id: \.self) { d in
                                        levelButton(label: "\(d) DIGITS", baseW: baseW) {
                                            // 桁数を記憶してステップ2へ
                                            selectedDigit = d
                                        }
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
        .overlay(alignment: .topLeading) {
            // ★変更：戻るボタンの挙動を2段階に対応させる
            Button(action: {
                if selectedDigit != nil {
                    // 口数選びの画面なら、桁数選びに戻る
                    SoundManager.instance.playSound(name: "tap") // または backSound
                    selectedDigit = nil
                } else {
                    // 桁数選びの画面なら、前の画面（タイトルなど）に戻る
                    onBack()
                }
            }) {
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
            SoundManager.instance.playSound(name: "tap")
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
