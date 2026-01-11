//
//  GhostSelectView.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/08.
//

import SwiftUI

struct GhostSelectView: View {
    @ObservedObject var ghostManager: GhostManager
    let mode: GameMode
    var onSelect: (LevelConfig, GhostRecord) -> Void
    var onBack: () -> Void

    @State private var scrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    @State private var containerHeight: CGFloat = 0

    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    var body: some View {
        ZStack(alignment: .trailing) {
            // 画面全体の背景
            Color.black.opacity(0.9).ignoresSafeArea()

            GeometryReader { containerGeo in
                ScrollView {
                    // ★ spacingを -1 にすることで、画像の継ぎ目の隙間を強制的に消しますわ
                    VStack(spacing: -1) {
                        
                        // 1. 巻物の頭
                        Image("makimono_head")
                            .resizable()
                            .scaledToFit()
                            .frame(width: isPad ? 700 : 380)

                        // 2. 巻物の中身（背景とレコードを一体化）
                        // ここがレコードの量に合わせて伸び縮みする部分ですわ
                        VStack(spacing: 15) {
                            Text("[ GHOST SELECT : \(mode.rawValue.uppercased()) ]")
                                .font(.custom("Edo SZ", size: isPad ? 35 : 22))
                                .fontWeight(.black)
                                .padding(.top, 10)

                            let filteredRecords = ghostManager.records.filter { $0.mode == mode }

                            if filteredRecords.isEmpty {
                                Text("NO RECORDS FOUND")
                                    .font(.custom("Edo SZ", size: 20))
                                    .padding(.vertical, 100)
                            } else {
                                ForEach(filteredRecords) { record in
                                    ghostRecordButton(record)
                                }
                            }

                            // 戻るボタンも中身と一緒に動くようにここに置きますわ
                            Button(action: onBack) {
                                ZStack {
                                    Image("button")
                                        .resizable()
                                        .frame(width: 140, height: 55)
                                    Text("BACK")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.black)
                                }
                            }
                            .padding(.top, 30)
                            .padding(.bottom, 10)
                        }
                        .padding(.horizontal, isPad ? 120 : 50)
                        // ★ ここで背景に middle を指定し、VStackの高さ一杯に広げますわ
                        .background(
                            Image("makimono_middle")
                                .resizable()
                                .padding(.horizontal, isPad ? 10 : 5) // 左右の端を head に合わせる微調整
                        )

                        // 3. 巻物の底
                        Image("makimono_bottom")
                            .resizable()
                            .scaledToFit()
                            .frame(width: isPad ? 700 : 380)
                    }
                    // 全体の高さを測って力士アイコンの計算に使いますわ
                    .background(GeometryReader { contentGeo in
                        Color.clear.onAppear {
                            contentHeight = contentGeo.size.height
                            containerHeight = containerGeo.size.height
                        }
                        .onChange(of: contentGeo.frame(in: .named("scroll")).minY) { newValue in
                            scrollOffset = newValue
                        }
                    })
                }
                .coordinateSpace(name: "scroll")
                .ignoresSafeArea()
            }

            // 右側の物差しと力士（インジケーター）
            rulerIndicator()
        }
    }

    // --- レコードボタンのデザイン ---
    private func ghostRecordButton(_ record: GhostRecord) -> some View {
        Button(action: {
            let config = recoverConfig(from: record)
            onSelect(config, record)
        }) {
            ZStack {
                Image("record")
                    .resizable()
                    .frame(height: isPad ? 110 : 75)
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(record.configLabel)
                            .font(.custom("Edo SZ", size: isPad ? 24 : 18))
                            .foregroundColor(.black)
                        Text(record.date, style: .date)
                            .font(.caption).foregroundColor(.black.opacity(0.6))
                    }
                    Spacer()
                    Text("\(String(format: "%.1f", record.solveIntervals.reduce(0,+)))s")
                        .font(.custom("Edo SZ", size: isPad ? 26 : 19))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 30)
            }
        }
    }

    // --- 右側の物差しインジケーター ---
    private func rulerIndicator() -> some View {
        ZStack(alignment: .top) {
            Image("ruler")
                .resizable()
                .frame(width: isPad ? 40 : 25, height: isPad ? 600 : 350)
                .opacity(0.5)
            
            let totalScrollable = contentHeight - containerHeight
            let progress = totalScrollable > 0 ? (scrollOffset / totalScrollable) : 0
            let clampedProgress = min(max(-progress, 0), 1)
            
            Image("icon_sumo")
                .resizable()
                .frame(width: isPad ? 60 : 40, height: isPad ? 60 : 40)
                .offset(y: clampedProgress * (isPad ? 540 : 310))
        }
        .padding(.trailing, isPad ? 40 : 15)
        .zIndex(10)
    }

    // レコードからの復元ロジック
    func recoverConfig(from record: GhostRecord) -> LevelConfig {
        let digits = record.configLabel.compactMap { Int(String($0)) }
        return LevelConfig(mode: mode, digits: digits.first ?? 1, digitsRight: digits.last ?? 1)
    }
}
