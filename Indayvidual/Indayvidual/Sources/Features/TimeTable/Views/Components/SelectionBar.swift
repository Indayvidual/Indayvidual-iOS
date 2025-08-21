//
//  SelectionBar.swift
//  Indayvidual
//
//  Created by 장주리 on 7/31/25.
//

import SwiftUI

struct SelectionBar: View {
    let title: String
    let isSelected: Bool
    let iconName: String
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 10) {
                Text(title)
                    .font(.pretendMedium14)
                    .foregroundColor(isSelected ? .black : .gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(iconName)
                    .resizable()
                    .frame(width: 15, height: 15)
            }
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
        .buttonStyle(PlainButtonStyle())
    }
}
