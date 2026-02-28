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
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: GhostRecord.self)
        } catch {
            fatalError("SwiftDataの初期化に失敗しました: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(GhostManager(modelContext: container.mainContext))
        }
        .modelContainer(container)
    }
}
