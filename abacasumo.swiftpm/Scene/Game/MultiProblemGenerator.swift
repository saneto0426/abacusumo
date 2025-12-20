//
//  MultiProblemGenerator.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/20.
//
class MultiProblemGenerator: ProblemGeneratable {
    func makeQuiz(config: LevelConfig) -> (numbers: [Int], answer: Int) {
        let range1 = calculateRange(digits: config.digits) // 例: 2桁
        let range2 = calculateRange(digits: 1)             // かける数は1桁に固定（例）
        
        let num1 = Int.random(in: range1)
        let num2 = Int.random(in: range2)
        
        return ([num1, num2], num1 * num2)
    }
}

