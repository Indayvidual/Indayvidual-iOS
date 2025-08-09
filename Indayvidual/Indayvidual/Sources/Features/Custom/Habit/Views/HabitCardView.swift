//
//  HabitCardView.swift
//  Indayvidual
//
//  Created by 김도연 on 7/23/25.
//

import SwiftUI

struct HabitCardView: View {
    @ObservedObject var calendarVM: CustomCalendarViewModel
    var habit: MyHabitModel
    var onToggle: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    private var isToggleDisabled: Bool {
            // 오늘보다 일 단위로 엄격히 큰 경우에만 disable
            Calendar.current.compare(
                calendarVM.selectDate,
                to: Date(),
                toGranularity: .day
            ) == .orderedDescending
        }

    var body: some View {
        HStack {
            Button {
                onToggle()
            } label: {
                let imageName = isToggleDisabled ? "square" : (habit.isSelected ? "checkmark.square.fill" : "square")
                Image(systemName: imageName)
                    .foregroundColor(.black)
            }
            .disabled(isToggleDisabled)

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
        .opacity(isToggleDisabled ? 0.6 : 1)  
        .foregroundStyle(.gray700)
        .padding()
        .background(Color(habit.colorName))
        .cornerRadius(16, corners: .allCorners)
    }
}

