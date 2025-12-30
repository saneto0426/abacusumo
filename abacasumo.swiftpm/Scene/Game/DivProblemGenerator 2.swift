//
//  DivProblemGenerator 2.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/20.
//


class DivProblemGenerator: ProblemGeneratable {
    func makeQuiz(config: LevelConfig) -> (numbers: [Int], answer: Int) {
        // 1. まず「答え」と「割る数」をランダムに作る
        let answerRange = calculateRange(digits: config.digits) // 答えが何桁か
        let divisorRange = calculateRange(digits: 1)            // 割る数は1桁に固定
        
        let answer = Int.random(in: answerRange)
        let divisor = Int.random(in: divisorRange)
        
        // 2. 逆算して「割られる数」を作る（これで必ず割り切れる）
        let dividend = answer * divisor
        
        return ([dividend, divisor], answer)
    }
}