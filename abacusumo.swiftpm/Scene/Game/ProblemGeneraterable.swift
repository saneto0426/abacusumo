//問題作成
//  ProbremMake.swift
//  abacasumo
//
//  Created by 🐣 on 2025/11/17.
//


import Foundation

protocol ProblemGeneratable {
    func makeQuiz(config: LevelConfig) -> (numbers: [Int], answer: Int)
}

extension ProblemGeneratable {
    func calculateRange(digits: Int) -> ClosedRange<Int> {
        let minVal = Int(pow(10.0, Double(digits - 1)))
        let maxVal = Int(pow(10.0, Double(digits))) - 1
        return minVal...maxVal
    }
}
