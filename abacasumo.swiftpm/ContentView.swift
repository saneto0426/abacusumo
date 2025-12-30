import SwiftUI

// --- 画面管理用の定義 ---
enum GameMode {
    case addition, multiplication, division
}

enum AppScreen {
    case title
    case game(mode: GameMode)
}

struct ContentView: View {
    @State private var currentScreen: AppScreen = .title
    
    var body: some View {
        Group {
            switch currentScreen {
            case .title:
                TitleView { selectedMode in
                    currentScreen = .game(mode: selectedMode)
                }
            case .game(let mode):
                GameView(mode: mode) {
                    currentScreen = .title // タイトルに戻る
                }
            }
        }
    }
}
