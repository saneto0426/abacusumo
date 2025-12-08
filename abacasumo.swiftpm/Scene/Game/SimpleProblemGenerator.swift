//足し算問題生成
//  AdditionalGenerator.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/01.
//

// Sources/Model/SimpleProblemGenerator.swift
import Foundation

class SimpleProblemGenerator: ProblemGeneratable {

    func makeQuiz(config: LevelConfig) -> (numbers: [Int], answer: Int) {
        var numbers: [Int] = []
        var currentTotal = 0  // 今の合計値を覚えておく
        
        // Protocol Extensionにある機能を呼び出す（自分で書かなくてOK）
        let range = calculateRange(digits: config.digits)
        
        for i in 0..<config.count {
            // 1. まず数字の候補を作る
            var num = Int.random(in: range)
            
            // 2. 引き算にするか決める
            // 条件: 「設定ON」かつ「2個目以降」かつ「引いても合計がマイナスにならない」
            if config.allowSubtraction && i > 0 && (currentTotal - num >= 0) {
                
                // 50%くらいの確率で引き算にする
                if Bool.random() {
                    num = -num // 数字をマイナスにする！
                }
            }
            
            // 3. リストに追加＆合計更新
            numbers.append(num)
            currentTotal += num
        }
        
        return (numbers, currentTotal)
    }
}
