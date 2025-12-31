

import SwiftUI

struct ContentView: View {
    @StateObject var ghostManager = GhostManager()
    @State private var selectedConfig: LevelConfig? = nil
    @State private var selectedGhost: GhostRecord? = nil

    var body: some View {
        if let config = selectedConfig {
            GameView(ghostManager: ghostManager, config: config, ghostToBeat: selectedGhost) {
                selectedConfig = nil
                selectedGhost = nil
            }
        } else {
            NavigationView {
                List {
                    Section("みとり算") {
                        ForEach(1...4, id: \.self) { d in
                            Button("\(d)桁 5口") { play(.addition, d, 1, 5) }
                        }
                    }
                    Section("掛け算") {
                        // 文字列をIDにすることでエラーを回避します
                        let pairs = ["1x1", "2x1", "2x2", "3x1", "3x2", "3x3"]
                        ForEach(pairs, id: \.self) { p in
                            Button("\(p)") {
                                let parts = p.split(separator: "x").map { Int($0)! }
                                play(.multiplication, parts[0], parts[1])
                            }
                        }
                    }
                    Section("割り算") {
                        let pairs = ["2/1", "3/1", "3/2", "4/1", "4/2"]
                        ForEach(pairs, id: \.self) { p in
                            Button("\(p.replacingOccurrences(of: "/", with: "÷"))") {
                                let parts = p.split(separator: "/").map { Int($0)! }
                                play(.division, parts[0], parts[1])
                            }
                        }
                    }
                }
                .navigationTitle("そろばん暗算")
            }
        }
    }

    func play(_ mode: GameMode, _ d1: Int, _ d2: Int = 1, _ count: Int = 5) {
        let config = LevelConfig(mode: mode, digits: d1, digitsRight: d2, count: count)
        selectedGhost = ghostManager.records.last(where: { $0.mode == mode && $0.configLabel == config.label })
        selectedConfig = config
    }
}
