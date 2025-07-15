//
//  CustomCalendarView.swift
//  Indayvidual
//
//  Created by 장주리 on 7/8/25.
//

import SwiftUI

struct CustomCalendarView: View {
    @ObservedObject var calendarViewModel: CustomCalendarViewModel

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CalendarHeaderView(calendarViewModel: calendarViewModel)
                WeekdayHeaderView()
                calendarContentView
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)
            .padding(.bottom, 23)
        }
        .frame(width: 320)
        .background(Color.white)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(red: 242/255, green: 242/255, blue: 247/255), lineWidth: 0.078)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 9.5, x: 2, y: 3)
    }

    @ViewBuilder
    private var calendarContentView: some View {
        if calendarViewModel.calendarMode == .month {
            MonthlyCalendarView(calendarViewModel: calendarViewModel)
        } else {
            WeeklyCalendarView(calendarViewModel: calendarViewModel)
        }
    }
}

// 캘린더 헤더
struct CalendarHeaderView: View {
    @ObservedObject var calendarViewModel: CustomCalendarViewModel

    private var yearAndMonth: (year: String, month: String) {
        let ym = calendarViewModel.getYearAndMonthString(currentDate: calendarViewModel.displayedMonthDate)
        return (year: ym[0], month: ym[1])
    }

    var body: some View {
        HStack {
            Text("\(yearAndMonth.month)월")
                .font(.pretendSemiBold16)
                .foregroundStyle(Color(red: 78/255, green: 80/255, blue: 82/255)) // gray700 → #4E5052

            Spacer().frame(width: 8.9)

            Text("\(yearAndMonth.year)년")
                .font(.pretendSemiBold16)
                .foregroundStyle(Color(red: 78/255, green: 80/255, blue: 82/255)) // gray700 → #4E5052

            Spacer()

            toggleButton
            previousButton
            Spacer().frame(width: 7.8)
            nextButton
        }
        .padding(.bottom, 20)
    }

    private var toggleButton: some View {
        Button {
            calendarViewModel.toggleCalendarMode()
        } label: {
            Text(calendarViewModel.calendarMode == .month ? "월" : "주")
                .font(.pretendSemiBold15)
                .frame(width: 29, height: 27)
                .foregroundStyle(Color(red: 28/255, green: 30/255, blue: 32/255)) // gray900 → #1C1E20
                .background(Color(red: 242/255, green: 244/255, blue: 246/255))
                .cornerRadius(9)
        }
    }

    private var previousButton: some View {
        Button(action: {
            calendarViewModel.moveCalendar(by: -1)
        }) {
            Image(.mingcuteLeftFill)
        }
    }

    private var nextButton: some View {
        Button(action: {
            calendarViewModel.moveCalendar(by: 1)
        }) {
            Image(.mingcuteRightFill)
        }
    }
}

// 요일 헤더
struct WeekdayHeaderView: View {
    private let weekday = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

    var body: some View {
        HStack(spacing: 26) {
            ForEach(weekday, id: \.self) { day in
                Text(day)
                    .font(.pretendMedium13)
                    .frame(width: 19, height: 16)
            }
        }
        .padding(.bottom, 20)
    }
}

// 월 캘린더
struct MonthlyCalendarView: View {
    @ObservedObject var calendarViewModel: CustomCalendarViewModel

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 30), count: 7)
    private let rowCount: CGFloat = 6
    private let itemHeight: CGFloat = 30

    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(calendarViewModel.extractDate(baseDate: calendarViewModel.displayedMonthDate)) { value in
                if value.day != -1 {
                    DateButton(
                        value: value,
                        calendarViewModel: calendarViewModel,
                        selectDate: calendarViewModel.selectDate,
                        onSelectDate: calendarViewModel.selectDate(_:)
                    )
                } else {
                    Color.clear
                        .frame(width: 30, height: 30) // 빈 칸에도 크기 유지
                }
            }
        }
        .frame(height: calculateMaxHeight())
    }

    private func calculateMaxHeight() -> CGFloat {
        (itemHeight * rowCount) + (rowCount - 1)
    }
}

// 주 캘린더
struct WeeklyCalendarView: View {
    @ObservedObject var calendarViewModel: CustomCalendarViewModel
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(getThisWeekDateValues()) { dateValue in
                DateButton(
                    value: dateValue,
                    calendarViewModel: calendarViewModel,
                    selectDate: calendarViewModel.selectDate,
                    onSelectDate: calendarViewModel.selectDate(_:)
                )
            }
        }
    }
    
    private func getThisWeekDateValues() -> [DateValue] {
        let calendar = Calendar.current
        let selectedDate = calendarViewModel.selectDate
        let weekday = calendar.component(.weekday, from: selectedDate)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: selectedDate)!
        
        return (0..<7).compactMap { offset in
            if let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek) {
                let day = calendar.component(.day, from: date)
                return DateValue(day: day, date: date)
            }
            return nil
        }
    }
}

// 일자 버튼
struct DateButton: View {
    var value: DateValue
    @ObservedObject var calendarViewModel: CustomCalendarViewModel
    var selectDate: Date
    var onSelectDate: (Date) -> Void
        
    private var isToday: Bool {
        Calendar.current.isDateInToday(value.date)
    }
        
    private var isSelected: Bool {
        calendarViewModel.isSameDay(date1: value.date, date2: selectDate)
    }
        
    var body: some View {
        Button {
            onSelectDate(value.date)
        } label: {
            Text("\(Calendar.current.component(.day, from: value.date))")
                .font(.pretendMedium13)
                .foregroundColor(isSelected ? .white : Color(red: 78/255, green: 80/255, blue: 82/255)) // gray700 → #4E5052
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(
                            isSelected ? .black :
                                (isToday ? Color(red: 215/255, green: 217/255, blue: 219/255) : Color.clear)
                )
            )
        }
    }
}

#Preview {
    CustomCalendarView(calendarViewModel: CustomCalendarViewModel())
}
