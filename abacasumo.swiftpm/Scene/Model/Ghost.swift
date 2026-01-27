//
//  Ghost.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/08.
//

import Foundation

enum GameMode: String, Codable, CaseIterable {
    case addition = "みとり"
    case multiplication = "かけ"
    case division = "わり"
}

struct LevelConfig: Equatable {
    var mode: GameMode
    var digits: Int        // 左側の桁数（見取りの桁数）
    var digitsRight: Int = 1 // 右側の桁数（掛ける数・割る数）
    var count: Int = 5       // 見取りの口数
    var allowSubtraction: Bool = true

    var label: String {
        switch mode {
        case .addition: return "\(digits)桁\(count)口"
        case .multiplication: return "\(digits)x\(digitsRight)"
        case .division: return "\(digits)/\(digitsRight)"
        }
    }
}

struct GhostRecord: Codable, Identifiable {
    var id = UUID()
    let mode: GameMode
    let configLabel: String
    let solveIntervals: [TimeInterval]
    let date: Date
    var playerName: String // ★追加: プレイヤー名
}

class GhostManager: ObservableObject {
    @Published var records: [GhostRecord] = []
    private let saveKey = "GhostRecords_v1"

    init() { load() }

    func saveRecord(_ record: GhostRecord) {
        records.append(record)
        // 各モードごとに最新50件に絞る
        let grouped = Dictionary(grouping: records, by: { $0.mode })
        var limited: [GhostRecord] = []
        for (_, items) in grouped {
            limited.append(contentsOf: items.suffix(50))
        }
        records = limited
        save()
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([GhostRecord].self, from: data) {
            records = decoded
        }
    }
}
//コアデータ・swiftデータ
