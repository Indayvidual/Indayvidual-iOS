//
//  CustomCaledarViewModel.swift
//  Indayvidual
//
//  Created by 장주리 on 7/8/25.
//

import Foundation
import SwiftUI

final class CustomCalendarViewModel: ObservableObject {
    @Published var currentDate: Date = Date() // 오늘 날짜
    @Published var selectDate: Date = Date()
    @Published var checkingDate: Date = Date()
    @Published var popupDate: Bool = false
    @Published var calendarMode: CalendarMode = .month

    // 월 이동 계산 대신, 직접 월 정보를 담는 변수로 변경
    @Published var displayedMonthDate: Date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!

    // 연, 월 String 반환
    func getYearAndMonthString(currentDate: Date) -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.M"
        let components = formatter.string(from: currentDate).split(separator: ".")
        return components.map { String($0) }
    }

    // 현재 월 기준으로 달력 날짜 데이터 생성
    func extractDate(currentMonth: Int) -> [DateValue] {
        let calendar = Calendar.current
        guard let monthDate = calendar.date(byAdding: .month, value: currentMonth, to: currentDate) else { return [] }

        var days: [DateValue] = []

        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate))!
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)

        // 앞쪽 공백 (-1)
        for _ in 0..<firstWeekday - 1 {
            days.append(DateValue(day: -1, date: Date()))
        }

        // 실제 날짜
        let range = calendar.range(of: .day, in: .month, for: monthDate)!
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(DateValue(day: day, date: date))
            }
        }

        return days
    }

    // 날짜 비교
    func isSameDay(date1: Date, date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }

    // 월 이동
    func moveMonth(by value: Int) {
        let calendar = Calendar.current

        if let newMonthDate = calendar.date(byAdding: .month, value: value, to: displayedMonthDate) {
            displayedMonthDate = newMonthDate
        }

        if let newSelectedDate = calendar.date(byAdding: .month, value: value, to: selectDate) {
            selectDate = newSelectedDate
        }
    }

    // 주 단위 날짜 이동 (selectDate만 변경)
    func moveWeek(byWeeks value: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: value * 7, to: selectDate) {
            selectDate(newDate)
        }
    }

    // 캘린더 모드에 따른 이동 함수
    func moveCalendar(by value: Int) {
        switch calendarMode {
        case .month:
            moveMonth(by: value)
        case .week:
            moveWeek(byWeeks: value)
        }
    }

    // 모드 전환
    func toggleCalendarMode() {
        calendarMode = (calendarMode == .month) ? .week : .month
    }

    // 날짜 선택 함수 (날짜 및 월 동기화)
    func selectDate(_ date: Date) {
        selectDate = date
        checkingDate = date
        popupDate = true

        let calendar = Calendar.current
        let selectedMonth = calendar.component(.month, from: date)
        let displayedMonth = calendar.component(.month, from: displayedMonthDate)
        let selectedYear = calendar.component(.year, from: date)
        let displayedYear = calendar.component(.year, from: displayedMonthDate)

        if selectedMonth != displayedMonth || selectedYear != displayedYear {
            displayedMonthDate = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        }
    }
    
    func extractDate(baseDate: Date) -> [DateValue] {
        let calendar = Calendar.current
        let monthDate = calendar.date(from: calendar.dateComponents([.year, .month], from: baseDate)) ?? Date()

        var days: [DateValue] = []

        let firstOfMonth = monthDate
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)

        for _ in 0..<firstWeekday - 1 {
            days.append(DateValue(day: -1, date: Date()))
        }

        let range = calendar.range(of: .day, in: .month, for: monthDate)!
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(DateValue(day: day, date: date))
            }
        }

        return days
    }

}
