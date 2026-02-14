//
//  GhostSelectView.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/08.
//

import SwiftUI
import SwiftData // ★これを忘れずに！

struct GhostSelectView: View {
    // データベースから「日付の新しい順」に全データを自動取得します
    @Query(sort: \GhostRecord.date, order: .reverse) private var allRecords: [GhostRecord]
    
    // 前の画面から受け取るもの
//    @ObservedObject var ghostManager: GhostManager
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
                    VStack(spacing: 0) {
                        
                        // 1. 巻物の上
                        Image("makimono_bottom")
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(y: -1)
                            .frame(width: geo.size.width)

                        // 2. 巻物の中身
                        VStack(spacing: 20) {
                            Text("[ GHOST SELECT : \(mode.rawValue.uppercased()) ]")
                                .font(.custom("Edo SZ", size: geo.size.width > 600 ? 35 : 24))
                                .fontWeight(.black)
                                .padding(.top, 10)

                            // ★ここが修正ポイント！
                            // Managerからではなく、@Queryで取った allRecords からフィルタリングします
                            let filteredRecords = allRecords.filter { $0.mode == mode }

                            if filteredRecords.isEmpty {
                                Text("NO RECORDS FOUND")
                                    .font(.custom("Papyrus", size: 20))
                                    .padding(.vertical, 100)
                            } else {
                                ForEach(filteredRecords) { record in
                                    ghostRecordButton(record, screenWidth: geo.size.width)
                                }
                            }

                            Button(action: onBack) {
                                ZStack {
                                    Image("key").resizable().frame(width: 140, height: 55)
                                    Text("BACK").font(.system(size: 18, weight: .bold)).foregroundColor(.black)
                                }
                            }
                            .padding(.vertical, 30)
                        }
                        .padding(.horizontal, geo.size.width * 0.1)
                        .frame(width: geo.size.width)
                        .background(
                            Image("makimono_middle")
                                .resizable()
                                .offset(x: geo.size.width > 600 ? 0 : 2)
                        )

                        // 3. 巻物の下
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
                        .onChange(of: contentGeo.frame(in: .named("scroll")).minY) { _, newValue in
                            scrollOffset = newValue
                        }
                    })
                }
                .coordinateSpace(name: "scroll")
                .ignoresSafeArea()

                rulerIndicator(screenHeight: geo.size.height)
            }
        }
    }
    
    // --- 以下、ボタンやデザインの関数はそのままでOK ---
    
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
                        Text("\(record.playerName) の記録")
                            .font(.custom("Papyrus", size: screenWidth > 600 ? 16 : 12))
                            .foregroundColor(.black)
                        
                        Text(record.configLabel)
                            .font(.custom("Papyrus", size: screenWidth > 600 ? 24 : 18))
                        
                        Text(record.date, style: .date)
                            .font(.caption).foregroundColor(.black.opacity(0.6))
                    }
                    Spacer()
                    Text("\(String(format: "%.1f", record.solveIntervals.reduce(0,+)))s")
                        .font(.custom("Papyrus", size: screenWidth > 600 ? 26 : 20))
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
            // ラベルから数字だけを取り出す
            let digits = record.configLabel.compactMap { Int(String($0)) }
            
            // 修正点: digitsRight: ... の部分を削除しました
            // mode と digits だけ渡せばOKです
            return LevelConfig(mode: mode, digits: digits.first ?? 1)
        }
}
