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
                
                // 1ページ目：そろばん・フラッシュ暗算とは？
                TutorialPageTemplate1(
                    title: "What's an abacus?",
                    imageName: "studyingRabit",
                    description: "The abacus is a traditional calculator.\nThis game is based on 'Flash Anzan' (mental abacus).\nLearning the basics will help you master this game!",
                    showNextArrow: true
                )
                .containerRelativeFrame(.vertical)
                
                // 2ページ目：そろばんの形
                TutorialPageTemplate1(
                    title: "What's abacus?",
                    imageName: "abacus",
                    description:"A standard Japanese abacus has one bead\non top and four at the bottom.\nWhile there are other versions,\nthis is the most common style in Japan.",
                    showNextArrow: true
                )
                .containerRelativeFrame(.vertical)
                
            
                TutorialPageTemplate1(
                    title: "How to use",
                    imageName: "abacus",
                    description: "Upper bead is 5.\nLower beads are 1.",
                    showNextArrow: true
                )
                .containerRelativeFrame(.vertical)
                
              
                TutorialPageTemplate2(showNextArrow: true)
                    .containerRelativeFrame(.vertical)
                
                
                TutorialPageTemplate5(showNextArrow: true)
                    .containerRelativeFrame(.vertical)
                
                CarryPartnersPage(showNextArrow: true)
                    .containerRelativeFrame(.vertical)
                
                // 2ページ目：足し算（繰り上がり）
                CarryAdditionPage(showNextArrow: true)
                    .containerRelativeFrame(.vertical)
                
                // 3ページ目：引き算（繰り下がり）
                CarrySubtractionPage(showNextArrow: true)
                    .containerRelativeFrame(.vertical)
                
             
                TutorialPageTemplate1(
                    title: "You're Ready!",
                    imageName: "studyingRabit",
                    description: "Great job! You've mastered the basics of the abacus.\nIf you're new to 'Flash Anzan',\nbe sure to check out that tutorial next!",
                    showNextArrow: false
                )
                .containerRelativeFrame(.vertical)
                
            }
            .scrollTargetLayout() 
        }
        .scrollTargetBehavior(.paging)
    }
}
