//
//  WeeklyHabitView.swift
//  Indayvidual
//
//  Created by 김도연 on 7/30/25.
//

import SwiftUI

struct WeeklyHabitView: View {
    var sharedVM: CustomViewModel
    
    let days = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"]
    
    var body: some View {
        ScrollView {
            ZStack {
                RoundedRectangle(cornerRadius: 11)
                    .fill(.white)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("나의 습관")
                        .font(.pretendSemiBold22)
                    
                    // 요일 헤더
                    HStack {
                        Text("") // 첫 칸 비워서 헤더 정렬
                            .frame(width: 60, alignment: .leading)
                        ForEach(days, id: \.self) { day in
                            Text(day)
                                .font(.pretendSemiBold10)
                                .frame(width: 32, height: 32)
                        }
                    }
                    
                    //습관별 체크
                    ForEach(Array(sharedVM.habits.enumerated()), id: \.element.id) { index, habit in
                        HStack {
                            Text(habit.title)
                                .font(.pretendSemiBold10)
                                .frame(width: 60, alignment: .leading)
                            ForEach(0..<7) { i in
                                RoundedRectangle(cornerRadius: 3)
                                    .frame(width: 32, height: 32)
                                    .foregroundStyle(habit.isSelected ? Color(habit.colorName) : .gray500) //TODO: API연결 시 habit.checks[i]로 수정
                            }
                        }
                    }
                }
                .padding()
            }
            .padding()
            .padding(.vertical)
        }
    }
}
