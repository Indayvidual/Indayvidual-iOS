//
//  WeeklyHabitView.swift
//  Indayvidual
//
//  Created by 김도연 on 7/30/25.
//

import SwiftUI

struct WeeklyHabitView: View {
    var showTitle: Bool = true      // "나의 습관" 제목 출력 여부
    var showShadow: Bool = true     // 백그라운드 그림자 여부
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
                    Text("") // 첫 칸 비워 정렬
                        .frame(width: 40, alignment: .leading)
                    ForEach(days, id: \.self) { day in
                        Text(day)
                            .font(.pretendSemiBold10)
                            .frame(width: 28, height: 28)
                    }
                }
                
                // 습관별 주간 체크 박스
                ForEach(sharedVM.weeklyHabits, id: \.id) { habit in
                    HStack {
                        Text(habit.title)
                            .lineLimit(2)                                   // 두 줄로 출력 제한
                            .font(.pretendSemiBold10)
                            .frame(width: 40, alignment: .leading)
                        
                        ForEach(0..<7, id: \.self) { idx in
                            let checked = habit.checks.indices.contains(idx) && habit.checks[idx]   // 체크 확인
                            RoundedRectangle(cornerRadius: 3)
                                .frame(width: 28, height: 28)
                                .foregroundStyle(checked ? Color(habit.colorName) : Color.gray.opacity(0.5)) // 체크 여부에 따라 습관 컬러 혹은 gray 출력
                        }
                    }
                }
            }
            .padding()
        }
        .padding(.horizontal, 6)
        .shadow(color: showShadow ? Color.black.opacity(0.08) : .clear,
                radius: 9.5, x: 2, y: 3)
    }
}
