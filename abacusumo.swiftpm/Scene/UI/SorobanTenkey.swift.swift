//
//  SorobanTenkey.swift.swift
//  Sum-o
//
//  Created by 🐣 on 2026/01/27.
//



import SwiftUI

struct SorobanTenkey: View {
    @Binding var userInput: String
    let actionLabel: String
    var onAction: () -> Void
    let isPad: Bool

    // そろばんの軸（縦列）ごとのボタン配置
    let columns = [
        ["1", "4", "7", "C"],
        ["2", "5", "8", "0"],
        ["3", "6", "9", "S"]
    ]

    var body: some View {
        HStack(spacing: isPad ? 14 : 5) { // 列の間隔
            ForEach(0..<3) { colIndex in
                VStack(spacing: isPad ? 0 : 12) { // 玉の上下間隔
                    ForEach(columns[colIndex], id: \.self) { key in
                        Button(action: {
                            if key == "S" { onAction() }
                            else if key == "C" { userInput = "" }
                            else { userInput += key }
                        }) {
                            ZStack {
                                Image("key")
                                    .resizable()
                                    .frame(width: isPad ? 120 : 58, height: isPad ? 88 : 44)
                                
                                Text(key == "S" ? actionLabel : key)
                                    .font(.custom("Papyrus", size: isPad ? 44 : 26))
                                    .font(.system(size: key == "S" ? (isPad ? 18 : 10) : (isPad ? 28 : 18), weight: .black))
                                    .foregroundColor(key == "S" ? .green : (key == "C" ? .red : .black))
                            }
                            .offset(y: isPad ? 30 : 20)
                        }
                    }
                }
            }
        }
        .offset(y: isPad ? 150 : 20)
    }
}
