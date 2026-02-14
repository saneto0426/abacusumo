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
//    var digitsRight: Int = 1 // 右側の桁数（掛ける数・割る数）
    var count: Int = 5       // 見取りの口数
    var allowSubtraction: Bool = true
    
    var label: String {
            // switch文も不要になり、シンプルになります
            return "\(digits)桁\(count)口"
        }

//    var label: String {
//        switch mode {
//        case .addition: return "\(digits)digits"
//        case .multiplication: return "\(digits)x\(digitsRight)"
//        case .division: return "\(digits)/\(digitsRight)"
//        }
//    }
}



//コアデータ・swiftデータ
