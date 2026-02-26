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
           
            // 1. 日付順に全データを取得するディスクリプタ
            let descriptor = FetchDescriptor<GhostRecord>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            
            if let allRecords = try? modelContext.fetch(descriptor) {
                // 2. メモリ上で「今のモード」のものだけを抜き出す
                let targetRecords = allRecords.filter { $0.mode == mode }
                
                // 3. 50件を超えていたら削除する
                if targetRecords.count > 50 {
                    let excess = targetRecords.suffix(from: 50)
                    for record in excess {
                        modelContext.delete(record)
                    }
                }
            }
        }
}
