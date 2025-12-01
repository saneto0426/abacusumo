//足し算問題生成
//  AdditionalGenerator.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/01.
//

class AdditionalGenerator : ProblemGeneraterable{
    func makeQuiz(digit: Int, count: Int) -> (numbers: [Int], answer: Int) {
        var numbers: [Int] = []
        
        for _ in 0..<count {
            numbers.append(Int.random(in: 1...9))
        }
    }
}
