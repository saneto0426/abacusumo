//
//  MyApp.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/01.
//
import SwiftUI
import SwiftData

@main
struct MyApp: App {
    // データベースの入れ物
    let container: ModelContainer

    init() {
        do {
            // ★ここが超重要！
            // "Item.self" ではなく "GhostRecord.self" になっていますか？
            // これがないと保存時にクラッシュします。
            container = try ModelContainer(for: GhostRecord.self)
        } catch {
            fatalError("SwiftDataの初期化に失敗しました: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Managerにデータベースへの鍵(mainContext)を渡して、アプリ全体に配る
                .environmentObject(GhostManager(modelContext: container.mainContext))
        }
        // ここも GhostRecord.self が含まれているコンテナを指定
        .modelContainer(container)
    }
}
