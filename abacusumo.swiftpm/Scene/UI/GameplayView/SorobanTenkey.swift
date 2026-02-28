//
//  SorobanTenkey.swift.swift
//  Sum-o
//
//  Created by 🐣 on 2026/01/27.
//

import SwiftUI

struct SorobanTenkey: View {
    // 親から受け取る「基準となる幅」
    let baseW: CGFloat
    
    let isGameOver: Bool
    let isAnswering: Bool
    let onAction: (String) -> Void
    
    // キー配列 (システム上はすべて "S" として扱います)
    private let columns = [
        ["1", "4", "7", "C"],
        ["2", "5", "8", "0"],
        ["3", "6", "9", "S"]
    ]

    var body: some View {
        // 3列のボタン配置
        HStack(spacing: baseW * 0.05) {
            
            // --- 左の飾り画像 ---
            VStack {
                Spacer()
                Image("keys")
                    .resizable()
                    .scaledToFit()
                    .frame(width: baseW * 0.18)
                    .offset(y: -baseW * 0.165)
                    .allowsHitTesting(false) // ★重要: これでボタンを邪魔しません
                Spacer()
            }
            .frame(height: baseW * 0.8)
            
            
            // --- 真ん中のテンキー ---
            ForEach(0..<3) { col in
                VStack(spacing: baseW * 0.015) {
                    ForEach(columns[col], id: \.self) { key in
                        Button(action: {
                            onAction(key) // 押されたら "S" など元の文字をそのまま送る
                        }) {
                            ZStack {
                                // 背景のひし形画像
                                Image("key")
                                    .resizable().scaledToFit()
                                    .frame(width: baseW * 0.2, height: baseW * 0.2)
                                
                                // ★修正ポイント: "S"ボタンだけ状態に合わせて記号(アイコン)に変える
                                if key == "S" {
                                    if isGameOver {
                                        // 状態1: リトライ
                                        Image(systemName: "arrow.counterclockwise")
                                            .font(.system(size: baseW * 0.08, weight: .black))
                                            .foregroundColor(.orange)
                                            .offset(y: baseW * 0.005) // 既存の微調整を適用
                                    } else if isAnswering {
                                        // 状態2: 回答の決定
                                        Image(systemName: "checkmark")
                                            .font(.system(size: baseW * 0.08, weight: .black))
                                            .foregroundColor(.green)
                                            .offset(y: baseW * 0.005)
                                    } else {
                                        // 状態3: 開始・次へ進む
                                        Image(systemName: "play.fill")
                                            .font(.system(size: baseW * 0.08, weight: .black))
                                            .foregroundColor(.orange)
                                            .offset(y: baseW * 0.005)
                                    }
                                } else {
                                    // S以外の通常キー（数字とC）
                                    let labelColor = (key == "C" ? Color.red : Color.black)
                                    
                                    Text(key)
                                        .font(.system(size: baseW * 0.08, weight: .black, design: .rounded))
                                        .foregroundColor(labelColor)
                                        .offset(y: baseW * 0.005)
                                }
                            }
                            // 当たり判定のサイズと形
                            .frame(width: baseW * 0.18, height: baseW * 0.14)
                            .contentShape(Diamond())
                            // 形とサイズが決まった後に全体を上にズラす
                            .offset(y: -baseW * 0.075)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            // --- 右の飾り画像 ---
            VStack {
                Spacer()
                Image("keys")
                    .resizable()
                    .scaledToFit()
                    .frame(width: baseW * 0.18)
                    .offset(y: -baseW * 0.165)
                    .allowsHitTesting(false)
                Spacer()
            }
            .frame(height: baseW * 0.8)
        }
    }
}

// ひし形（ダイヤ型）の定義【修正版：当たり判定縮小機能付き】
struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        let paddingX = rect.width * 0.05
        let paddingY = rect.height * 0.05
        
        let smallRect = rect.insetBy(dx: paddingX, dy: paddingY)
        
        var path = Path()
        path.move(to: CGPoint(x: smallRect.midX, y: smallRect.minY))
        path.addLine(to: CGPoint(x: smallRect.maxX, y: smallRect.midY))
        path.addLine(to: CGPoint(x: smallRect.midX, y: smallRect.maxY))
        path.addLine(to: CGPoint(x: smallRect.minX, y: smallRect.midY))
        
        path.closeSubpath()
        return path
    }
}
