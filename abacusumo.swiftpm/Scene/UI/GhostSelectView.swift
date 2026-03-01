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
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    

    // フィルタリング後に、選択された条件でソートする
    private var filteredRecords: [GhostRecord] {
        let baseRecords = allRecords.filter { $0.mode == mode }
            
        switch sortOption {
        case .newest:
            return baseRecords.sorted { $0.date > $1.date }
        case .oldest:
            return baseRecords.sorted { $0.date < $1.date }
        case .fastest:
                // 合計タイムを計算して短い順（速い順）に並べる
            return baseRecords.sorted {
        $0.solveIntervals.reduce(0, +) < $1.solveIntervals.reduce(0, +)
                }
            }
        }

    var body: some View {
        GeometryReader { geo in
            ZStack() {
                
                if filteredRecords.isEmpty {
                                    // --- レコードがない時の表示 ---
                                    
                    // ★ ZStackを使って「左上」基準で画面全体に配置する
                    ZStack(alignment: .topLeading) {
                        
                        // 1. 中央のイラスト（と専用背景）
                        VStack {
                            Spacer()
                            Image("NoRecords") // お化けのイラスト
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.size.width * 0.5) // サイズはここで微調整
                                .opacity(0.7)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // 画面全体に広げる
                        
                        // 2. 戻るボタン（レコードがある時と全く同じサイズ・位置に固定！）
                        .overlay(alignment: .topLeading) {
                            Button(action: onBack) {
                                ZStack {
                                    Image("back") // 戻るアイコン
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: isPad ? 45 : 18, height: isPad ? 45 : 18)
                                        .foregroundColor(.white)
                                }
                            }
                            // GameViewと位置を合わせるためのパディング
                            .padding(.top, isPad ? 40 : 50)
                            .padding(.leading, 20)
                        }
                    }
                                    
                                } else {
                    // --- レコードがある時の表示（セーブスロット形式） ---
                    
                    // ★ 1. 全体を固定するためのVStack（ScrollViewから変更）
                    VStack(spacing: 0) {
                        
                      
                        // --- 固定の巻物ヘッダー ---
                        Image("makimono_head")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width)
                            .overlay(alignment: .topLeading) {
                                // 戻るボタン（既存のまま）
                                Button(action: onBack) {
                                    Image("back")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: isPad ? 45 : 30)
                                        .foregroundColor(.white)
                                }
                                .padding(.top, isPad ? 40 : 50)
                                .padding(.leading, 20)
                            }
                            .overlay(alignment: .topTrailing) {
                                // ソートボタンのサイズ設定
                                let btnW: CGFloat = isPad ? 120 : 100 // 横幅
                                let btnH: CGFloat = isPad ? 40 : 30   // 高さ

                                Menu {
                                    Picker("Sort", selection: $sortOption) {
                                        ForEach(RecordSortOption.allCases, id: \.self) { option in
                                            Text(option.rawValue).tag(option)
                                        }
                                    }
                                } label: {
                                    ZStack {
                                        // ボタンの背景画像
                                        Image("button")
                                            .resizable()
                                            // .aspectRatio(contentMode: .fit) // ← これがあるとサイズ固定しにくいので外します
                                            .frame(width: btnW, height: btnH)
                                            .opacity(0.8) // 巻物に馴染ませる
                                        
                                        // ボタンの文字とアイコン
                                        HStack(spacing: 5) {
                                            Image(systemName: "arrow.up.arrow.down")
                                                .font(.system(size: isPad ? 18 : 12))
                                            Text(sortOption.rawValue)
                                                .font(.custom("Papyrus", size: isPad ? 20 : 13))
                                                .fontWeight(.bold)
                                        }
                                        .foregroundColor(.black.opacity(0.8))
                                    }
                                }
                                .padding(.top, isPad ? 40 : 50) // 戻るボタンと高さを合わせる
                                .padding(.trailing, isPad ? 10 : 10)
                            }
                        // --- ★ 2. ここから下だけがスクロールする！ ---
                        GeometryReader { scrollGeo in
                            ScrollView {
                                VStack(spacing: 20) {
                                    // ソートメニュー
                                
                                    
                                    // レコード一覧
                                    ForEach(filteredRecords) { record in
                                        ghostRecordButton(record, screenWidth: geo.size.width)
                                    }
                                }
                                .padding(.vertical, 20)
                                .padding(.horizontal, geo.size.width * 0.1)
                                .frame(maxWidth: .infinity)
                                
                                // スクロールインジケーター用の計算
                                .background(GeometryReader { contentGeo in
                                    Color.clear.onAppear {
                                        contentHeight = contentGeo.size.height
                                        containerHeight = scrollGeo.size.height
                                    }
                                    .onChange(of: contentGeo.frame(in: .named("scroll")).minY) { _, newValue in
                                        scrollOffset = newValue
                                        // ★ おまけ: レコードを消した時にも再計算されるように追加しておくと安心です
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
            }.frame(width: geo.size.width, height: geo.size.height)
        }
            .background(
                Image("backscreen_t")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
        
    }


    
    private func ghostRecordButton(_ record: GhostRecord, screenWidth: CGFloat) -> some View {
            // ★ 2. HStackで囲んで、右側にゴミ箱ボタンを配置
            HStack(spacing: 15) {
                
                // --- 元のレコード選択ボタン ---
                Button(action: {
                    // ★追加：ゴーストを選択した時に ghostSound.mp3 を鳴らす！
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
                                // ★ 日本語だった箇所を英語に修正！
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
                
                // --- ★ 3. ゴミ箱（削除）ボタン ---
                Button(action: {
                    // ★追加：ゴミ箱ボタンを押した時も戻るボタンと同じ音を鳴らす！
                    SoundManager.instance.playSound(name: "backSound", ext: "mp3")
                    
                    // データベースからこのレコードを削除
                    modelContext.delete(record)
                }) {
                    Image("trash")
                        .resizable()
                        .frame(width:screenWidth * 0.05, height: screenWidth * 0.05 )
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
