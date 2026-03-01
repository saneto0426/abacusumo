//
//  Ghost.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/08.
//

import Foundation

enum GameMode: String, Codable, CaseIterable {
    case addition = "ADDITION"
//    case multiplication = "MULTIPLICATION"
//    case division =  "DIVISION"
}

struct LevelConfig: Equatable {
    var mode: GameMode
    var digits: Int        // 左側の桁数（見取りの桁数）
    var count: Int = 5       // 見取りの口数
    var allowSubtraction: Bool = true
    
    var label: String {
        // ★UI（ProblemSelectView）の表示と合わせる
        return "\(digits) DIGITS (\(count) NUMS)"
    }
}


