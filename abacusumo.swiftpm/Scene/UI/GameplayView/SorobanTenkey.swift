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
    
    // キー配列
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
                            onAction(key)
                        }) {
                            ZStack {
                                // 画像 (オフセットはここでかけず、後でまとめてかけます)
                                Image("key")
                                    .resizable().scaledToFit()
                                    .frame(width: baseW * 0.2, height: baseW * 0.2)
                                    // ここでの .offset は削除 (下に移動)
                                
                                // ラベルの出し分け
                                let labelText = key == "S" ? (isGameOver ? "RETRY" : (isAnswering ? "OK" : "ST")) : key
                                let labelColor = key == "S" ? Color.green : (key == "C" ? Color.red : Color.black)
                                
                                Text(labelText)
                                    .font(.custom("Papyrus", size: baseW * 0.08))
                                    .font(.system(size: key == "S" ? baseW * 0.04 : baseW * 0.08, weight: .black))
                                    .foregroundColor(labelColor)
                                    // 微調整: 画像との相対位置だけ合わせる（少し下にずらす）
                                    .offset(y: baseW * 0.01)
                            }
                            // ★修正ポイント: ここで当たり判定のサイズを決める
                            .frame(width: baseW * 0.18, height: baseW * 0.14)
//                            .overlay(
//                                    Diamond()
////                                        .fill(Color.red.opacity(0.5)) // 半透明の赤
//                                        .allowsHitTesting(false)      // デバッグ表示がタップを邪魔しないように
//                                )
                            
                            // ★修正ポイント: 当たり判定の形を決める
                            .contentShape(Diamond())
                            
                            // ★修正ポイント: 形とサイズが決まった「後」に、全体を上にズラす！
                            // これで「見た目」も「当たり判定」も一緒に上に移動します
                            .offset(y: -baseW * 0.08)
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
                    .allowsHitTesting(false) // ★重要: これでボタンを邪魔しません
                Spacer()
            }
            .frame(height: baseW * 0.8)
        }
    }
}

// ひし形（ダイヤ型）の定義
// ひし形（ダイヤ型）の定義【修正版：当たり判定縮小機能付き】
struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        // ★ここが魔法の調整！
        // 枠(rect)から、内側に 20% くらい隙間(padding)を空けた「小さい枠」を作ります
        // この 0.2 を 0.3 にするともっと狭く、0.1 にすると広くなります
        let paddingX = rect.width * 0.05
        let paddingY = rect.height * 0.05
        
        // 小さくなった枠
        let smallRect = rect.insetBy(dx: paddingX, dy: paddingY)
        
        var path = Path()
        // 上
        path.move(to: CGPoint(x: smallRect.midX, y: smallRect.minY))
        // 右
        path.addLine(to: CGPoint(x: smallRect.maxX, y: smallRect.midY))
        // 下
        path.addLine(to: CGPoint(x: smallRect.midX, y: smallRect.maxY))
        // 左
        path.addLine(to: CGPoint(x: smallRect.minX, y: smallRect.midY))
        
        path.closeSubpath()
        return path
    }
}
