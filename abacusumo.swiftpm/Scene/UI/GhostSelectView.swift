//
//  GhostSelectView.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/08.
//

import SwiftUI
import SwiftData

struct GhostSelectView: View {
    @Query(sort: \GhostRecord.date, order: .reverse) private var allRecords: [GhostRecord]
    @Environment(\.modelContext) private var modelContext
    
    let mode: GameMode
    var onSelect: (LevelConfig, GhostRecord) -> Void
    var onBack: () -> Void

    @State private var scrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    @State private var containerHeight: CGFloat = 0

    @State private var sortOption: RecordSortOption = .newest
    
    @State private var searchText: String = ""
    
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }


    private var filteredRecords: [GhostRecord] {
        
        var baseRecords = allRecords.filter { $0.mode == mode }
        
       
        if !searchText.isEmpty {
            baseRecords = baseRecords.filter { $0.playerName.localizedCaseInsensitiveContains(searchText) }
        }
            
        //  ソート適用
        switch sortOption {
        case .newest:
            return baseRecords.sorted { $0.date > $1.date }
        case .oldest:
            return baseRecords.sorted { $0.date < $1.date }
        case .fastest:
            return baseRecords.sorted {
                $0.solveIntervals.reduce(0, +) < $1.solveIntervals.reduce(0, +)
            }
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack() {
                // レコードが一つもない場合の表示（検索結果が空の場合とは別）
                if allRecords.filter({ $0.mode == mode }).isEmpty {
                    ZStack(alignment: .topLeading) {
                        VStack {
                            Spacer()
                            Image("NoRecords")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.size.width * 0.5)
                                .opacity(0.7)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        .overlay(alignment: .topLeading) {
                            Button(action: onBack) {
                                Image("back")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: isPad ? 45 : 18, height: isPad ? 45 : 18)
                                    .foregroundColor(.white)
                            }
                            .padding(.top, isPad ? 40 : 50)
                            .padding(.leading, 20)
                        }
                    }
                } else {
                    // --- レコードがある時の表示 ---
                    VStack(spacing: 0) {
                        
                        // --- 固定の巻物ヘッダー ---
                        Image("makimono_head")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width)
                            .overlay(
                                // ★ 黄色のエリアに要素を並べる
                                HStack(alignment: .center, spacing: 10) {
                                    // 1. 戻るボタン
                                    Button(action: onBack) {
                                        Image("back")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: isPad ? 40 : 25)
                                    }
                                    
                                    Spacer()
                                    
                                    // 2. ★検索欄
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .font(.system(size: isPad ? 18 : 12))
                                            .foregroundColor(.black.opacity(0.5))
                                        
                                        TextField("Search Name", text: $searchText)
                                            .font(.custom("Papyrus", size: isPad ? 18 : 12))
                                            .textFieldStyle(PlainTextFieldStyle())
                                            .submitLabel(.done)
                                        
                                    }
                                    .padding(.horizontal, 30)
                                    .frame(width: geo.size.width * 0.35, height: isPad ? 40 : 30)
                                    .background(
                                        Image("button")
                                            .resizable()
                                            
                                    )
                                    
                                    // 3. ソートボタン
                                    Menu {
                                        Picker("Sort", selection: $sortOption) {
                                            ForEach(RecordSortOption.allCases, id: \.self) { option in
                                                Text(option.rawValue).tag(option)
                                            }
                                        }
                                    } label: {
                                        ZStack {
                                            Image("button")
                                                .resizable()
                                                .frame(width: isPad ? 110 : 85, height: isPad ? 40 : 30)
                                                .opacity(0.8)
                                            
                                            HStack(spacing: 3) {
                                                Image(systemName: "arrow.up.arrow.down")
                                                    .font(.system(size: isPad ? 14 : 10))
                                                Text(sortOption.rawValue)
                                                    .font(.custom("Papyrus", size: isPad ? 16 : 11))
                                                    .fontWeight(.bold)
                                            }
                                            .foregroundColor(.black.opacity(0.8))
                                        }
                                    }
                                }
                                .padding(.horizontal, isPad ? 40 : 25)
                                .padding(.top, isPad ? 42 : 52) // 黄色の帯の位置に合わせて微調整してください
                                , alignment: .top
                            )

                        // --- リスト表示エリア ---
                        GeometryReader { scrollGeo in
                            ScrollView {
                                VStack(spacing: 20) {
                                    if filteredRecords.isEmpty {
                                        Text("No ghosts found")
                                            .font(.custom("Papyrus", size: 20))
                                            .foregroundColor(.gray)
                                            .padding(.top, 50)
                                    }
                                    
                                    ForEach(filteredRecords) { record in
                                        ghostRecordButton(record, screenWidth: geo.size.width)
                                    }
                                }
                                .padding(.vertical, 20)
                                .padding(.horizontal, geo.size.width * 0.1)
                                .frame(maxWidth: .infinity)
                                .background(GeometryReader { contentGeo in
                                    Color.clear.onAppear {
                                        contentHeight = contentGeo.size.height
                                        containerHeight = scrollGeo.size.height
                                    }
                                    .onChange(of: contentGeo.frame(in: .named("scroll")).minY) { _, newValue in
                                        scrollOffset = newValue
                                        contentHeight = contentGeo.size.height
                                        containerHeight = scrollGeo.size.height
                                    }
                                })
                            }
                            .coordinateSpace(name: "scroll")
                        }
                        .frame(width: geo.size.width)
                        .background(
                            Image("makimono_middle")
                                .resizable()
                                .frame(width: 1024)
                                .scaleEffect(x: geo.size.width / 1024, y: 1.0)
                        )
                        .clipped()
                        
                        // --- 固定の巻物フッター ---
                        Image("makimono_bottom")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width)
                    }
                    .ignoresSafeArea()
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .background(
            Image("backscreen_t")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }

    
    private func ghostRecordButton(_ record: GhostRecord, screenWidth: CGFloat) -> some View {
        HStack(spacing: 15) {
            Button(action: {
                SoundManager.instance.playSound(name: "ghostSound", ext: "mp3")
                let config = recoverConfig(from: record)
                onSelect(config, record)
            }) {
                ZStack {
                    Image("record")
                        .resizable()
                        .frame(height: screenWidth > 600 ? 110 : 80)
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(record.playerName)'s Record")
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
            
            Button(action: {
                SoundManager.instance.playSound(name: "backSound", ext: "mp3")
                modelContext.delete(record)
            }) {
                Image("trash")
                    .resizable()
                    .frame(width: screenWidth * 0.05, height: screenWidth * 0.05 )
            }
        }
    }

    func recoverConfig(from record: GhostRecord) -> LevelConfig {
        let extractedNumbers = record.configLabel.compactMap { Int(String($0)) }
        let d = extractedNumbers.first ?? 1
        let c = extractedNumbers.count > 1 ? extractedNumbers[1] : 5
        return LevelConfig(mode: mode, digits: d, count: c)
    }
}
