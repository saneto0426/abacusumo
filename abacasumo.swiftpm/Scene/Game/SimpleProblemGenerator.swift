//足し算問題生成
//  AdditionalGenerator.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/01.
//

import Foundation

class SimpleProblemGenerator: ProblemGeneratable {
    func makeQuiz(config: LevelConfig) -> (numbers: [Int], answer: Int) {
        var numbers: [Int] = []
        var currentTotal = 0
        let range = calculateRange(digits: config.digits)
        
        for i in 0..<config.count {
            var num = Int.random(in: range)
            if config.allowSubtraction && i > 0 && (currentTotal - num >= 0) {
                if Bool.random() { num = -num }
            }
            numbers.append(num)
            currentTotal += num
        }
        return (numbers, currentTotal)
    }
}
