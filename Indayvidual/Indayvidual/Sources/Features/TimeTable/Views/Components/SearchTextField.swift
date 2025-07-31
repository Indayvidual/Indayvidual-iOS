//
//  SearchTextField.swift
//  Indayvidual
//
//  Created by 장주리 on 7/31/25.
//

import SwiftUI

struct SearchTextField: View {
    @Binding var text: String
    var onTextChanged: (String) -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            TextField("학교 이름 검색", text: $text)
                .font(.pretendMedium14)
                .foregroundColor(.black)
                .disableAutocorrection(true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onChange(of: text) { oldValue, newValue in
                    onTextChanged(newValue)
                }
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image("ic_remove")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(.gray500))
                        .background(Color(.gray50))
                }
            }
            
            Image("Group")
                .resizable()
                .frame(width: 15, height: 15)
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .frame(height: 48)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .inset(by: 0.5)
                .stroke(Color(red: 0.84, green: 0.85, blue: 0.86), lineWidth: 1)
        )
    }
}
