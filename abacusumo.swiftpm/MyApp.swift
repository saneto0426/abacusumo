//
//  MyApp.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/01.
//
import SwiftUI
import CoreText

@main
struct MyApp: App {

   
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

func  registerCustomFont(size: CGFloat) -> Font {
        // カスタムフォントがダメでも、標準の「Serif（明朝体風）」を
        // 「重さ最高（Black）」にすれば、かなり強そうに見えますわ！
        return .system(size: size, weight: .heavy, design: .serif)
    }
