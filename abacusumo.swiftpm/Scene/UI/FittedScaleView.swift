//
//  FittedScaleView.swift
//  Sum-o
//
//  Created by 🐣 on 2026/02/02.
//

// FittedScaleView.swift
import SwiftUI

// 基準サイズに合わせて中身を拡大縮小する便利な箱
struct FittedScaleView<Content: View>: View {
    let designWidth: CGFloat
    let content: Content

    init(designWidth: CGFloat, @ViewBuilder content: () -> Content) {
        self.designWidth = designWidth
        self.content = content()
    }

    var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / designWidth
            
            // 画面の中央に配置
            ZStack {
                content
                    .scaleEffect(scale) // ここでズーム！
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}
