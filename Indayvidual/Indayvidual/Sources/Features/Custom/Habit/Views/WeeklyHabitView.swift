//
//  WeeklyHabitView.swift
//  Indayvidual
//
//  Created by 김도연 on 7/30/25.
//

import SwiftUI

struct WeeklyHabitView: View {
    var showTitle: Bool = true
    var showShadow: Bool = true
    var sharedVM: CustomViewModel
    
    
    let days = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"]
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
            VStack(alignment: .leading, spacing: 20) {
                if showTitle {
                    Text("나의 습관")
                        .font(.pretendSemiBold16)
                }
                
                // 요일 헤더
                HStack {
                    Text("") // 첫 칸 비워서 헤더 정렬
                        .frame(width: 40, alignment: .leading)
                    ForEach(days, id: \.self) { day in
                        Text(day)
                            .font(.pretendSemiBold10)
                            .frame(width: 28, height: 28)
                    }
                }
                
                //습관별 체크
                ForEach(Array(sharedVM.habits.enumerated()), id: \.element.id) { _, habit in
                    HStack {
                        Text(habit.title)
                            .font(.pretendSemiBold10)
                            .frame(width: 40, alignment: .leading)
                        
                        ForEach(0..<7, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 3)
                                .frame(width: 28, height: 28)
                                .foregroundStyle(
                                    (habit.checks.indices.contains(i) && habit.checks[i])
                                    ? Color(habit.colorName)
                                    : .gray500
                                )
                        }
                    }
                }
            }
            .padding()
        }
        .padding(.horizontal, 6)
        .shadow(color: showShadow ? Color.black.opacity(0.08) : .clear, radius: 9.5, x: 2, y: 3)
    }
}
