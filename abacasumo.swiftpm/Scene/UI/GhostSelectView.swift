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

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .trailing) {
                Color.black.ignoresSafeArea()

                ScrollView {
                    // 画像同士の隙間を消すために spacing: 0 に戻しますわ
                    VStack(spacing: 0) {
                        
                        // 1. 巻物の頭（画面幅ピッタリ）
                        Image("makimono_head")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width)

                        // 2. 巻物の中身（背景が画面幅いっぱいに広がりますわ）
                        VStack(spacing: 20) {
                            Text("[ GHOST SELECT : \(mode.rawValue.uppercased()) ]")
                                .font(.custom("Edo SZ", size: geo.size.width > 600 ? 35 : 24))
                                .fontWeight(.black)
                                .padding(.top, 10)

                            let filteredRecords = ghostManager.records.filter { $0.mode == mode }

                            if filteredRecords.isEmpty {
                                Text("NO RECORDS FOUND")
                                    .font(.custom("Edo SZ", size: 20))
                                    .padding(.vertical, 100)
                            } else {
                                ForEach(filteredRecords) { record in
                                    ghostRecordButton(record, screenWidth: geo.size.width)
                                }
                            }

                            Button(action: onBack) {
                                ZStack {
                                    Image("button").resizable().frame(width: 140, height: 55)
                                    Text("BACK").font(.system(size: 18, weight: .bold)).foregroundColor(.black)
                                }
                            }
                            .padding(.vertical, 30)
                        }
                        .padding(.horizontal, geo.size.width * 0.1) // 左右に10%の余白を設けてレコードを中央に
                        .frame(width: geo.size.width) // コンテンツエリア自体の幅を固定
                        .background(
                            Image("makimono_middle")
                                .resizable()
                                .offset(x: geo.size.width > 600 ? -4 : -2) // 微調整のオフセット
                        )

                        // 3. 巻物の底（画面幅ピッタリ）
                        Image("makimono_bottom")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width)
                    }
                    .background(GeometryReader { contentGeo in
                        Color.clear.onAppear {
                            contentHeight = contentGeo.size.height
                            containerHeight = geo.size.height
                        }
                        .onChange(of: contentGeo.frame(in: .named("scroll")).minY) { newValue in
                            scrollOffset = newValue
                        }
                    })
                }
                .coordinateSpace(name: "scroll")
                .ignoresSafeArea()

                // 右側の物差しインジケーター
                rulerIndicator(screenHeight: geo.size.height)
            }
        }
    }

    private func ghostRecordButton(_ record: GhostRecord, screenWidth: CGFloat) -> some View {
        Button(action: {
            let config = recoverConfig(from: record)
            onSelect(config, record)
        }) {
            ZStack {
                Image("record")
                    .resizable()
                    .frame(height: screenWidth > 600 ? 110 : 80)
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(record.configLabel)
                            .font(.custom("Edo SZ", size: screenWidth > 600 ? 24 : 18))
                        Text(record.date, style: .date)
                            .font(.caption).foregroundColor(.black.opacity(0.6))
                    }
                    Spacer()
                    Text("\(String(format: "%.1f", record.solveIntervals.reduce(0,+)))s")
                        .font(.custom("Edo SZ", size: screenWidth > 600 ? 26 : 20))
                }
                .padding(.horizontal, 25)
                .foregroundColor(.black)
            }
        }
    }

    private func rulerIndicator(screenHeight: CGFloat) -> some View {
        ZStack(alignment: .top) {
            Image("ruler").resizable().frame(width: 25, height: screenHeight * 0.6).opacity(0.5)
            let totalScrollable = contentHeight - containerHeight
            let progress = totalScrollable > 0 ? (scrollOffset / totalScrollable) : 0
            Image("icon_sumo").resizable().frame(width: 40, height: 40)
                .offset(y: min(max(-progress, 0), 1) * (screenHeight * 0.6 - 40))
        }
        .padding(.trailing, 10)
    }

    func recoverConfig(from record: GhostRecord) -> LevelConfig {
        let digits = record.configLabel.compactMap { Int(String($0)) }
        return LevelConfig(mode: mode, digits: digits.first ?? 1, digitsRight: digits.last ?? 1)
    }
}
