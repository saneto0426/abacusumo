//問題作成
//  ProbremMake.swift
//  abacasumo
//
//  Created by 🐣 on 2025/11/17.
//

import Foundation


struct LevelConfig {
    let digits: Int          // 桁数
    let count: Int           // 口数
    let allowSubtraction: Bool //引き算ありかどうか
}

protocol ProblemGeneraterable{
    //問題作成
    func makeQuiz(config: LevelConfig) -> (numbers: [Int], answer: Int)
    //問題開示
//    func show()
    
}
