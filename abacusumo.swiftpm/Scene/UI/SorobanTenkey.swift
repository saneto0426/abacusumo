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
        HStack(spacing: baseW * 0.035) {
            ForEach(0..<3) { col in
                VStack(spacing: baseW * 0.01) {
                    ForEach(columns[col], id: \.self) { key in
                        Button(action: {
                            onAction(key)
                        }) {
                            ZStack {
                                Image("key")
                                    .resizable().scaledToFit()
                                    .frame(width: baseW * 0.2)
                                    .offset(y: -baseW * 0.065)// ボタンサイズも相対指定
                                    
                                
                                // ラベルの出し分け
                                let labelText = key == "S" ? (isGameOver ? "RETRY" : (isAnswering ? "OK" : "ST")) : key
                                let labelColor = key == "S" ? Color.green : (key == "C" ? Color.red : Color.black)
                                
                                Text(labelText)
                                    .font(.custom("Papyrus", size: baseW * 0.08)) // フォントサイズも自動
                                    .font(.system(size: key == "S" ? baseW * 0.04 : baseW * 0.08, weight: .black))
                                    .foregroundColor(labelColor)
                                    .offset(y: -baseW * 0.065)
                            }
                        }
                    }
                }
            }
        }
    }
}
