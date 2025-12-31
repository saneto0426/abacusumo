

import SwiftUI


enum AppScreen {
    case title
    case modeSelect(isGhostMode: Bool)
    case digitSelect(mode: GameMode)
    case ghostSelect(mode: GameMode)
    case game(config: LevelConfig, ghost: GhostRecord?)
}

struct ContentView: View {
    @StateObject var ghostManager = GhostManager()
    @State private var currentScreen: AppScreen = .title

    var body: some View {
        ZStack {
            switch currentScreen {
            case .title:
                TitleView(onStartSolo: { currentScreen = .modeSelect(isGhostMode: false) },
                          onStartGhost: { currentScreen = .modeSelect(isGhostMode: true) })
                
            case .modeSelect(let isGhost):
                ModeSelectView(isGhostMode: isGhost) { mode in
                    if isGhost {
                        currentScreen = .ghostSelect(mode: mode)
                    } else {
                        currentScreen = .digitSelect(mode: mode)
                    }
                } onBack: { currentScreen = .title }

            case .digitSelect(let mode):
                ProblemSelectView(mode: mode) { config in
                    currentScreen = .game(config: config, ghost: nil)
                } onBack: { currentScreen = .modeSelect(isGhostMode: false) }

            case .ghostSelect(let mode):
                GhostSelectView(ghostManager: ghostManager, mode: mode) { config, ghost in
                    currentScreen = .game(config: config, ghost: ghost)
                } onBack: { currentScreen = .modeSelect(isGhostMode: true) }

            case .game(let config, let ghost):
                GameView(ghostManager: ghostManager, config: config, ghostToBeat: ghost) {
                    currentScreen = .title
                }
            }
        }
    }
}
