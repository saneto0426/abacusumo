//
//  NameInputView.swift.swift
//  Sum-o
//
//  Created by 🐣 on 2026/01/27.
//

import SwiftUI

struct NameInputView: View {
    @Binding var inputName: String
    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        Color.black.opacity(0.6).ignoresSafeArea()
        
        VStack(spacing: 20) {
            Text("勝負あり！")
                .font(.custom("Edo SZ", size: 40))
                .foregroundColor(.white)
                .padding(.top, 20)
            
            Text("番付に名前を刻め")
                .font(.body)
                .foregroundColor(.white)
            
            TextField("名前を入力", text: $inputName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200)
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
            
            Button(action: onSave) {
                ZStack {
                    Image("key")
                        .resizable()
                        .frame(width: 140, height: 50)
                    Text("奉 納")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            .disabled(inputName.isEmpty)
            
            Button("保存せずに戻る") {
                onCancel()
            }
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.top, 10)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.systemBackground))
                .frame(width: 300, height: 350)
                .overlay(
                    RoundedRectangle(cornerRadius: 15).stroke(Color.black, lineWidth: 2)
                )
        )
    }
}
