import SwiftUI
import SwiftData
import AVFoundation

// 画面の遷移状態
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
                    
                    onStart: { _ in
                        currentScreen = .digitSelect(mode: .addition)
                    },
                   
                    onGhostMode: {
                        currentScreen = .ghostSelect(mode: .addition)
                    }
                )
                
            // ★ modeSelect のケースは削除しました
                
            case .digitSelect(let mode):
                ProblemSelectView(mode: mode) { config in
                    currentScreen = .game(config: config, ghost: nil)
                } onBack: {
           
                    SoundManager.instance.playSound(name: "backSound", ext: "mp3")
                    currentScreen = .title
                }

            case .ghostSelect(let mode):
            
                GhostSelectView(mode: mode) { config, ghost in
                    currentScreen = .game(config: config, ghost: ghost)
                } onBack: {
              
                    SoundManager.instance.playSound(name: "backSound", ext: "mp3")
                    currentScreen = .title
                }

            case .game(let config, let ghost):
                GameView(ghostManager: ghostManager, config: config, ghostToBeat: ghost) {
                   
                    SoundManager.instance.playSound(name: "backSound", ext: "mp3")
                    currentScreen = .title
                }
            }
        }
    }
}

@MainActor

class SoundManager {
    static let instance = SoundManager()
    

    private var sePlayers: [AVAudioPlayer] = []
    private var bgmPlayer: AVAudioPlayer?


    func playSound(name: String, ext: String = "wav") {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("SE: \(name).\(ext) が見つかりません")
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.play()
            
            
            sePlayers.append(player)
            
           
            sePlayers.removeAll { $0.isPlaying == false }
            
        } catch {
            print("SE再生エラー: \(error.localizedDescription)")
        }
    }


    func playBGM(name: String, ext: String = "mp3") {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("BGM: \(name).\(ext) が見つかりません")
            return
        }
        do {
            bgmPlayer = try AVAudioPlayer(contentsOf: url)
            bgmPlayer?.numberOfLoops = -1
            bgmPlayer?.play()
        } catch {
            print("BGM再生エラー: \(error.localizedDescription)")
        }
    }

    func stopBGM() {
        bgmPlayer?.stop()
    }
}
