//
//  GhostRecord.swift
//  Sum-o
//
//  Created by 🐣 on 2026/02/14.
//
import Foundation
import SwiftData





@MainActor // UIスレッドでの安全な動作を保証
class GhostManager: ObservableObject {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// 記録を保存し、各モード50件に制限する
    func saveRecord(_ record: GhostRecord) {
        modelContext.insert(record) // データベースに追加
        limitRecords(for: record.mode)
    }

    private func limitRecords(for mode: GameMode) {
        let modeRawValue = mode.rawValue
        // 特定のモードを日付の新しい順に取得するクエリ
        let descriptor = FetchDescriptor<GhostRecord>(
            predicate: #Predicate { $0.mode.rawValue == modeRawValue },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        if let allRecords = try? modelContext.fetch(descriptor), allRecords.count > 50 {
            let excess = allRecords.suffix(from: 50)
            for record in excess {
                modelContext.delete(record) // 古い50件以降を削除
            }
        }
    }
}
