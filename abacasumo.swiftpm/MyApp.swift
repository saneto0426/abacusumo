//
//  MyApp.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/01.
//


import SwiftUI

@main
struct MyApp: App {
    
    // ↓ ここに init() を追加してテストコードを書く
    init() {
        print("----- テスト開始 -----")
        
        let generator = SimpleProblemGenerator()
        // 2桁、5口、引き算あり
        let config = LevelConfig(digits: 2, count: 5, allowSubtraction: true)

        let quiz = generator.makeQuiz(config: config)

        print("生成された問題: \(quiz.numbers)")
        print("正解: \(quiz.answer)")
        
        print("----- テスト終了 -----")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
