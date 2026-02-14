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
    // SwiftDataの入れ物（Container）
    let container: ModelContainer

    init() {
        do {
            // 保存するモデル（GhostRecord）を登録
            container = try ModelContainer(for: GhostRecord.self)
        } catch {
            fatalError("SwiftDataの初期化に失敗: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                // アプリ全体で使うManagerに、データベースへの窓口（context）を渡して注入
                .environmentObject(GhostManager(modelContext: container.mainContext))
        }
        // これでアプリ全体がSwiftDataを使える状態になる
        .modelContainer(container)
    }
}
