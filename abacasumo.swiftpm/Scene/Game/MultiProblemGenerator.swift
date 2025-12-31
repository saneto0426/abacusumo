//
//  MultiProblemGenerator.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/20.
//
import Foundation

class MultiProblemGenerator: ProblemGeneratable {
    func makeQuiz(config: LevelConfig) -> (numbers: [Int], answer: Int) {
        let range1 = calculateRange(digits: config.digits)
        let range2 = calculateRange(digits: config.digitsRight)
        
        let num1 = Int.random(in: range1)
        let num2 = Int.random(in: range2)
        return ([num1, num2], num1 * num2)
    }
}
