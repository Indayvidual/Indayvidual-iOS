//
//  HabitCardView.swift
//  Indayvidual
//
//  Created by 김도연 on 7/23/25.
//

import SwiftUI

struct HabitCardView: View {
    var habit: MyHabitModel
    var onToggle: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        HStack {
            Button{
                onToggle()
            } label: {
                Image(systemName: habit.isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(.black)
            }

            Text(habit.title)
                .font(.pretendRegular15)
                .foregroundColor(.black)
                .padding(.leading, 8)

            Spacer()

            Menu {
                Button("수정하기", action: onEdit)
                Button("삭제하기", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis")
                    .frame(width: 24, height: 20)
                    .padding(.trailing, 8)
            }
        }
        .foregroundStyle(.gray700)
        .padding()
        .background(Color(habit.colorName))
        .cornerRadius(16, corners: .allCorners)
    }
}

