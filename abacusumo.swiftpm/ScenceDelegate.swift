//
//  ScenceDelegate.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/01.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // 1. シーンを取得
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // 2. ウィンドウを作る
        let window = UIWindow(windowScene: windowScene)
        
        // 3. ★ここ重要！ MainViewController を最初の画面に設定
        let mainVC = MainViewController()
        window.rootViewController = mainVC
        
        // 4. 表示する
        window.makeKeyAndVisible()
        self.window = window
    }
}
