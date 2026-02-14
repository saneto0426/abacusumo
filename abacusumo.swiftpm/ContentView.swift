import SwiftUI
import SwiftData

// 画面の遷移状態（modeSelect を削除しました）
enum AppScreen {
    case title
    case digitSelect(mode: GameMode)
    case ghostSelect(mode: GameMode)
    case game(config: LevelConfig, ghost: GhostRecord?)
}

struct ContentView: View {
    // MyAppから渡されたManagerを受け取る
    @EnvironmentObject var ghostManager: GhostManager
    
    @State private var currentScreen: AppScreen = .title

    var body: some View {
        ZStack {
            switch currentScreen {
            case .title:
                TitleView(
                    // ★変更点1: スタートボタンで、いきなり桁数選択へ（モードは .addition 固定）
                    onStart: { _ in
                        currentScreen = .digitSelect(mode: .addition)
                    },
                    // ★変更点2: ゴーストボタンで、いきなりゴースト一覧へ
                    onGhostMode: {
                        currentScreen = .ghostSelect(mode: .addition)
                    }
                )
                
            // ★ modeSelect のケースは削除しました
                
            case .digitSelect(let mode):
                ProblemSelectView(mode: mode) { config in
                    currentScreen = .game(config: config, ghost: nil)
                } onBack: {
                    // ★変更点3: 戻るときはタイトルへ
                    currentScreen = .title
                }

            case .ghostSelect(let mode):
                // ★修正: 引数から ghostManager を削除（GhostSelectView側で @Query を使うため不要）
                GhostSelectView(mode: mode) { config, ghost in
                    currentScreen = .game(config: config, ghost: ghost)
                } onBack: {
                    // ★変更点4: 戻るときはタイトルへ
                    currentScreen = .title
                }

            case .game(let config, let ghost):
                GameView(ghostManager: ghostManager, config: config, ghostToBeat: ghost) {
                    currentScreen = .title
                }
            }
        }
    }
}
