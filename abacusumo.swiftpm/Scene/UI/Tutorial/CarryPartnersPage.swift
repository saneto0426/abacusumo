//
//  CarryPartnersPage.swift
//  Sum-O
//
//  Created by 🐣 on 2026/03/01.
//
import SwiftUI

struct CarryPartnersPage: View {
    let showNextArrow: Bool
    
    // 表示アニメーション用
    @State private var showContent = false
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    
    let partners = [("1", "9"), ("2", "8"), ("3", "7"), ("4", "6"), ("5", "5")]
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            VStack(spacing: h * 0.02) {
                Spacer()
                
                // タイトル
                formatText("The *\"Partners\"*")
                    .font(.custom("Papyrus", size: w * 0.08)) // ★ 少しだけサイズダウン
                    .frame(maxWidth: .infinity, alignment: .center)
                
                
                VStack(spacing: 5) {
                    formatText("To calculate smoothly,\nremember pairs that make *10*!")
                        .font(.custom("Papyrus", size: w * (isPad ? 0.04 : 0.05)))
                        .multilineTextAlignment(.center)
                    
                    formatText("Use these pairs for\n*Carry Over* and *Borrowing*!")
                        .font(.custom("Papyrus", size: w * (isPad ? 0.035 : 0.045)))
                        .multilineTextAlignment(.center)
                        .padding(.top, 5)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
                
                // ペアのリスト
                VStack(spacing: h * 0.015) { // ★ リストの隙間も少し狭くしました
                    ForEach(partners, id: \.0) { p1, p2 in
                        HStack(spacing: w * 0.1) {
                            partnerCircle(num: p1, w: w)
                            
                            Image(systemName: "plus")
                                .font(.system(size: w * 0.06, weight: .bold))
                                .foregroundColor(.red)
                            
                            partnerCircle(num: p2, w: w)
                        }
                    }
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                Spacer()
                
                // 矢印（次がある場合）
                if showNextArrow {
                    TutorialArrowView(w: w)
                } else {
                    Spacer().frame(minHeight: h * 0.05)
                }
            }
            .frame(width: w, height: h)
            .onAppear {
                withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                    showContent = true
                }
            }
        }
    }
    
    // --- 🌟 *で囲んだ部分だけ赤くする魔法の関数 ---
    private func formatText(_ text: String) -> Text {
        let components = text.components(separatedBy: "*")
        var result = Text("")
        
        for (index, part) in components.enumerated() {
            if index % 2 == 1 {
                result = result + Text(part).foregroundColor(.red).fontWeight(.bold)
            } else {
                result = result + Text(part).foregroundColor(.black).fontWeight(.bold)
            }
        }
        return result
    }
    
    // --- 🌟 数字のデザインを「button画像」に変更 ---
    private func partnerCircle(num: String, w: CGFloat) -> some View {
        // ★ iPadのときはボタンを少し小さくして、縦にはみ出さないように計算！
        let circleW = isPad ? w * 0.12 : w * 0.15
        
        return ZStack {
            Image("button")
                .resizable()
                .scaledToFit()
                .frame(width: circleW * 1.2) // ★ circleW を基準に画像サイズを調整
            
            Text(num)
                .font(.custom("Papyrus", size: circleW * 0.5)) // ★ 文字サイズも連動
                .fontWeight(.bold)
                .foregroundColor(.black)
                .offset(y: -circleW * 0.0005)
        }
        .frame(width: circleW, height: circleW)
    }
}
