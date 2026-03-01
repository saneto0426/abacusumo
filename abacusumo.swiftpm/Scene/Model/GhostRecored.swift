//
//  GhostRecored.swift
//  Sum-o
//
//  Created by 🐣 on 2026/02/14.
//

import Foundation
import SwiftData

@Model 
class GhostRecord {
    @Attribute(.unique) var id: UUID // 重複保存を防止
    var mode: GameMode
    var configLabel: String
    var solveIntervals: [TimeInterval]
    var date: Date
    var playerName: String

    init(mode: GameMode, configLabel: String, solveIntervals: [TimeInterval], date: Date, playerName: String) {
        self.id = UUID()
        self.mode = mode
        self.configLabel = configLabel
        self.solveIntervals = solveIntervals
        self.date = date
        self.playerName = playerName
    }
}
