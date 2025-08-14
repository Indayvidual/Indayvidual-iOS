//
//  CalendarWithScheduleListView.swift
//  Indayvidual
//
//  Created by 김지민 on 8/14/25.
//

import SwiftUI

struct CalendarWithScheduleListView: View {
    @ObservedObject var calendarViewModel: CustomCalendarViewModel
    @ObservedObject var homeViewModel: HomeViewModel
    var showShadow: Bool = true
    var onDateSelected: ((Date) -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            CustomCalendarView(
                calendarViewModel: calendarViewModel,
                showShadow: false,
                onDateSelected: { date in
                    homeViewModel.fetchSchedules(for: date)
                    onDateSelected?(date) // 외부에도 전달
                }
            )



            if !homeViewModel.filteredSchedules.isEmpty {
                Divider()
                    .padding(.horizontal, 33)
                    .padding(.bottom, 15)

                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(homeViewModel.filteredSchedules, id: \.id) { schedule in
                            ScheduleCard(schedule: schedule)
                                .padding(.horizontal, 5)
                        }
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 33)
                }
                .frame(maxHeight: 60)
                .padding(.bottom, 16)
            }
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: showShadow ? .black.opacity(0.08) : .clear, radius: 4.75, x: 2, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .inset(by: 0.04)
                .stroke(Color(red: 0.95, green: 0.96, blue: 0.96), lineWidth: 0.07781)
        )
    }
}

struct ScheduleCard: View {
    let schedule: ScheduleItem

    var body: some View {
        HStack(spacing: 10) {
            if schedule.isAllDay {
                Text("하루종일")
                    .font(.pretendRegular14)
                    .foregroundColor(.gray700)
            } else if let start = schedule.startTime {
                Text("\(start.toString(format: "HH:mm")) ~ \(schedule.endTime?.toString(format: "HH:mm") ?? "")")
                    .font(.pretendRegular14)
                    .foregroundColor(.gray700)
            }
            Divider()
            Text(schedule.title)
                .font(.pretendRegular14)
                .lineLimit(1)
                .foregroundStyle(.gray900)
            Spacer()
        }
    }
}

#Preview {
    let calendarViewModel = CustomCalendarViewModel()
    let homeViewModel = HomeViewModel()
    // 테스트 일정
    homeViewModel.filteredSchedules = [
        ScheduleItem(id: 1, startTime: Date(), endTime: Date().addingTimeInterval(3600), title: "회의", color: .blue, isAllDay: false),
        ScheduleItem(id: 2, startTime: Date().addingTimeInterval(7200), endTime: Date().addingTimeInterval(10800), title: "점심 약속", color: .orange, isAllDay: false),
        ScheduleItem(id: 3, startTime: nil, endTime: nil, title: "휴가", color: .green, isAllDay: true)
    ]
    return CalendarWithScheduleListView(calendarViewModel: calendarViewModel, homeViewModel: homeViewModel)
}
