//
//  AbacusTutorialView.swift
//  Sum-o
//
//  Created by 🐣 on 2026/02/23.
//

import SwiftUI

// --- 1. チュートリアルの大枠（ページをまとめる場所） ---
struct AbacusTutorialView: View {
    var body: some View {
        // 縦方向のスクロールビュー（インジケーターは非表示）
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) { // ページ間の隙間をなくしてピタッとくっつける
                
                // 1ページ目（アップしてくれた手書きラフ画の内容）
                TutorialPageTemplate1(
                    title: "What's abacus?",
                    imageName: "studyingRabit", // ★ 手書きのそろばん画像（Assetsに追加してね！）
                    description: "Abacus is a tool to calculate.\nPeople in Japan and so on\nuse it.",
                    showNextArrow: true
                )
                .containerRelativeFrame(.vertical) // 親ビュー（巻物の内側）の高さにピッタリ合わせる
                
                // 2ページ目（例：次のスライドの中身）
                TutorialPageTemplate1(
                    title: "What's abacus?",
                    imageName: "abacus", // ★ 2ページ目用の画像
                    description:"A standard Japanese abacus has one bead\non top and four at the bottom.\nWhile there are other versions,\n this is the most common style in Japan.",
                    showNextArrow: true // 最後なので矢印を消す
                )
                .containerRelativeFrame(.vertical)
                
               
                
                TutorialPageTemplate2(showNextArrow: true) // 最後ならfalse、次があるならtrue
                                    .containerRelativeFrame(.vertical)
                
                TutorialPageTemplate5(showNextArrow: true)
                    .containerRelativeFrame(.vertical)
                
                TutorialPageTemplate1(
                    title: "How to use",
                    imageName: "abacus", // ★ 2ページ目用の画像
                    description: "Upper bead is 5.\nLower beads are 1.",
                    showNextArrow: false // 最後なので矢印を消す
                )
                .containerRelativeFrame(.vertical)
                
                
            }
            .scrollTargetLayout() // スクロールの基準をこのVStackにする
        }
        .scrollTargetBehavior(.paging) // ★ ここが魔法！スワイプでピタッとページが止まる
    }
}
