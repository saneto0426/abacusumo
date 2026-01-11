//
//  NumberPad.swift
//  abacasumo
//
//  Created by 🐣 on 2025/12/31.
//

//import SwiftUI
//
//struct NumberPad: View {
//    @Binding var userInput: String
//    let actionLabel: String
//    let actionColor: Color
//    var onAction: () -> Void
//    let rows = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"]]
//    var body: some View {
//        VStack(spacing: 12) {
//            ForEach(rows, id: \.self) { row in
//                HStack(spacing: 12) {
//                    ForEach(row, id: \.self) { label in
//                        NumberButton(label: label) { userInput += label }
//                    }
//                }
//            }
//            HStack(spacing: 12) {
//                NumberButton(label: "C", color: .red.opacity(0.8)) { userInput = "" }
//                NumberButton(label: "0") { userInput += "0" }
//                Button(action: onAction) {
//                    Text(actionLabel).font(.headline).bold()
//                        .frame(width: 80, height: 60)
//                        .background(actionColor).foregroundColor(.white).cornerRadius(12)
//                }
//            }
//        }
//    }
//}
//
//struct NumberButton: View {
//    let label: String
//    var color: Color = .gray
//    var action: () -> Void
//    var body: some View {
//        Button(action: { if label.count < 6 { action() } }) {
//            Text(label).font(.title2).bold()
//                .frame(width: 80, height: 60)
//                .background(color).foregroundColor(.white).cornerRadius(12)
//        }
//    }
//}
