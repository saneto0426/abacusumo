//
//  DivProblemGenerator 2.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/20.
//


import Foundation

class DivProblemGenerator: ProblemGeneratable {
    func makeQuiz(config: LevelConfig) -> (numbers: [Int], answer: Int) {
        // 答えの桁数 = 全体桁 - 割る数桁
        let ansDigits = max(1, config.digits - config.digitsRight)
        let answerRange = calculateRange(digits: ansDigits)
        let divisorRange = calculateRange(digits: config.digitsRight)
        
        let answer = Int.random(in: answerRange)
        let divisor = Int.random(in: divisorRange)
        let dividend = answer * divisor
        
        return ([dividend, divisor], answer)
    }
}
