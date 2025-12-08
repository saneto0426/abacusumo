//問題作成
//  ProbremMake.swift
//  abacasumo
//
//  Created by 🐣 on 2025/11/17.
//

// Sources/Model/ProblemGenerator.swift
import Foundation

// 設定データの定義
struct LevelConfig {
    let digits: Int           // 桁数
    let count: Int            // 口数
    let allowSubtraction: Bool // 引き算ありかどうか
}

// プロトコルの定義（タイポ修正：Generaterable -> Generatable）
protocol ProblemGeneratable {
    // 問題作成メソッドのルール
    func makeQuiz(config: LevelConfig) -> (numbers: [Int], answer: Int)
}

// 共通機能の拡張
extension ProblemGeneratable {
    // 桁数から数字の範囲（例: 2桁 -> 10〜99）を計算する共通メソッド
    // ここに書いておけば、実装側で書かなくてOKです！
    func calculateRange(digits: Int) -> ClosedRange<Int> {
        let d = max(1, digits) // 最低1桁は保証
        let min = Int(pow(10.0, Double(d - 1)))
        let max = Int(pow(10.0, Double(d))) - 1
        return min...max
    }
}
