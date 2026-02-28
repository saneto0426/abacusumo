//
//  GhostRecord.swift
//  Sum-o
//
//  Created by 🐣 on 2026/02/14.
//
import Foundation
import SwiftData





@MainActor
class GhostManager: ObservableObject {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// 記録を保存する（★制限をなくしました）
    func saveRecord(_ record: GhostRecord) {
        modelContext.insert(record) // データベースに追加するだけ！
    }
    
    // ※ limitRecords(for:) メソッドは丸ごと削除してOKです
}   

