//
//  HowToPlayView.swift
//  Sum-o
//
//  Created by 🐣 on 2026/02/23.
//
import SwiftUI
// --- 3. 遊び方チュートリアル（How to Play） ---
//struct HowToPlayView: View {
//    var body: some View {
//        ScrollView(.vertical, showsIndicators: false) {
//            VStack(spacing: 0) {
//                // 仮の1ページ目
//                TutorialPageTemplate(
//                    title: "How to Play",
//                    imageName: "mode", // ★ 後で画像を追加してね
//                    description: "There are two ways to play this game.\nFirst is Single Mode, where you play by yourself.\nThen there's Ghost Mode, \na 'pseudo-multiplayer' mode that lets you race \nagainst your own best times or the records of anyone else  \nwho has played on this device!",
//                    showNextArrow: false // ページを増やしたら true にする
//                )
//                .containerRelativeFrame(.vertical)
//            }
//            .scrollTargetLayout()
//        }
//        .scrollTargetBehavior(.paging)
//    }
//}

struct HowToPlayView: View {
    // ★ ここで「体験チュートリアルに飛ぶ」スイッチを管理する
    @State private var showInteractiveTutorial = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // 1ページ目（ゲームのルール説明など）
                TutorialPageTemplate1(
                    title: "How to Play",
                    imageName: "mode", // ★ 後で画像を追加してね
                    description: "There are two ways to play this game.\nFirst is Single Mode, where you play by yourself.\nThen there's Ghost Mode, \na 'pseudo-multiplayer' mode that lets you race \nagainst your own best times or the records of anyone else who has played on this device!",
                    showNextArrow: false // ページを増やしたら true にする
                  )
                .containerRelativeFrame(.vertical)
                TutorialPageTemplate3(showNextArrow: true) // ★ 次があるから true
                                    .containerRelativeFrame(.vertical)
                
                TutorialPageTemplate4(showNextArrow: true)
                                    .containerRelativeFrame(.vertical)
             
                // 2ページ目（体験チュートリアルへの誘導ボタン！）
                InteractiveLaunchPage(showInteractiveTutorial: $showInteractiveTutorial)
                    .containerRelativeFrame(.vertical)
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        // ★ ここでボタンが押されたら全画面で体験チュートリアルを被せる！
        .fullScreenCover(isPresented: $showInteractiveTutorial) {
            InteractiveTutorialView()
        }
    }
}

