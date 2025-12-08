//
//  Ghost.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/08.
//

import Foundation

struct Ghost: Codable, Identifiable {
    var id = UUID()           // データごとのユニークID
    let score: Int            // 正解数（スコア）
    let clearTime: TimeInterval // クリアにかかった時間
    let date: Date            // プレイした日時
    
    // 将来的に「どの問題でどう答えたか」を記録するならここに追記します
    // let logs: [ActionLog]
}
