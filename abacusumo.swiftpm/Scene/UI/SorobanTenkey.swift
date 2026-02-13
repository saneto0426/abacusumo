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
        // baseW を基準に隙間などを計算することで、上の枠とピッタリ合います
        HStack(spacing: baseW * 0.05) {
            VStack {
                            // 上下にSpacerを入れると、画像が上下中央に来ます
                            Spacer()
                            
                            Image("keys") // ← 左側に置きたい画像の名前
                                .resizable()
                                .scaledToFit()
                                .frame(width: baseW * 0.18) // 幅の調整 (0.2〜0.3くらいで調整)
                                .offset(y: -baseW * 0.165)   // 位置の微調整
                            
                            Spacer()
                        }.frame(height: baseW * 0.8) // エリアの高さを確保
            
            ForEach(0..<3) { col in
                VStack(spacing: baseW * 0.015) {
                    ForEach(columns[col], id: \.self) { key in
                        Button(action: {
                            onAction(key)
                        }) {
                            ZStack {
                                Image("key")
                                    .resizable().scaledToFit()
                                    .frame(width: baseW * 0.2, height: baseW * 0.2)
                                    .offset(y: -baseW * 0.08)// ボタンサイズも相対指定
                                    
                                
                                // ラベルの出し分け
                                let labelText = key == "S" ? (isGameOver ? "RETRY" : (isAnswering ? "OK" : "ST")) : key
                                let labelColor = key == "S" ? Color.green : (key == "C" ? Color.red : Color.black)
                                
                                Text(labelText)
                                    .font(.custom("Papyrus", size: baseW * 0.08)) // フォントサイズも自動
                                    .font(.system(size: key == "S" ? baseW * 0.04 : baseW * 0.08, weight: .black))
                                    .foregroundColor(labelColor)
                                    .offset(y: -baseW * 0.07)
                            }
                            // 当たり判定のサイズ調整（お好みで調整してください）
                            .frame(width: baseW * 0.18, height: baseW * 0.14)
                                    
                                    // ★「ひし形」の範囲だけ押せるようにします
                            .contentShape(Diamond())
                        }
                    }
                }
            }
            VStack {
                            Spacer()
                            
                            Image("keys") // ← 右側に置きたい画像の名前
                                .resizable()
                                .scaledToFit()
                                .frame(width: baseW * 0.18) // 幅の調整
                                .offset(y: -baseW * 0.165)   // 位置の微調整
                            
                            Spacer()
                        }
                        .frame(height: baseW * 0.8)
        }
    }
}
// ひし形（ダイヤ型）の定義
struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // 上
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        // 右
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        // 下
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        // 左
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}
