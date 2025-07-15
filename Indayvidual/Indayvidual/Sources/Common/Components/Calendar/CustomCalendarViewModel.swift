//
//  CustomCalendarViewModel.swift
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

    // 월 기준 날짜 (year, month 만 있는 Date, 시간은 00:00:00)
    @Published var displayedMonthDate: Date = {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        return calendar.date(from: components) ?? Date()
    }()

    // 연, 월 문자열 반환
    func getYearAndMonthString(currentDate: Date) -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.M"
        let components = formatter.string(from: currentDate).split(separator: ".")
        return components.map { String($0) }
    }

    // 날짜 비교 (년,월,일만 비교)
    func isSameDay(date1: Date, date2: Date) -> Bool {
        Calendar.current.isDate(date1, equalTo: date2, toGranularity: .day)
    }

    // 월 이동
    func moveMonth(by value: Int) {
        let calendar = Calendar.current

        if let newMonthDate = calendar.date(byAdding: .month, value: value, to: displayedMonthDate) {
            displayedMonthDate = calendar.startOfDay(for: newMonthDate)
        }

        if let newSelectedDate = calendar.date(byAdding: .month, value: value, to: selectDate) {
            selectDate = calendar.startOfDay(for: newSelectedDate)
        }
    }

    // 주 단위 이동 (selectDate만)
    func moveWeek(byWeeks value: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: value * 7, to: selectDate) {
            updateSelectedDate(newDate)
        }
    }

    // 캘린더 모드에 따라 이동
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

    // 날짜 선택 및 월 동기화
    func updateSelectedDate(_ date: Date) {
        let calendar = Calendar.current

        let startOfDay = calendar.startOfDay(for: date)

        selectDate = startOfDay
        checkingDate = startOfDay
        popupDate = true

        let selectedMonth = calendar.component(.month, from: startOfDay)
        let displayedMonth = calendar.component(.month, from: displayedMonthDate)
        let selectedYear = calendar.component(.year, from: startOfDay)
        let displayedYear = calendar.component(.year, from: displayedMonthDate)

        if selectedMonth != displayedMonth || selectedYear != displayedYear {
            if let newDisplayedDate = calendar.date(from: calendar.dateComponents([.year, .month], from: startOfDay)) {
                displayedMonthDate = newDisplayedDate
            }
        }
    }

    // 월 기준 날짜 배열 생성
    func extractDate(baseDate: Date) -> [DateValue] {
        let calendar = Calendar.current
        
        // baseDate에서 연,월 정보만 가져와 1일 0시 기준 날짜 생성
        guard let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: baseDate)) else {
            return []
        }
        
        // 첫날 자정으로 보정 (시간까지 00:00:00)
        let startOfFirstDay = calendar.startOfDay(for: firstOfMonth)
        
        var days: [DateValue] = []
        
        // 첫날의 요일 (1=일요일, 7=토요일)
        let firstWeekday = calendar.component(.weekday, from: startOfFirstDay)
        
        // 월 달력 앞 공백 처리 (첫 요일 전까지)
        for _ in 1..<firstWeekday {
            days.append(DateValue(day: -1, date: .distantPast))
        }
        
        // 해당 월의 전체 일 수 (예: 31일)
        guard let range = calendar.range(of: .day, in: .month, for: startOfFirstDay) else {
            return []
        }
        
        // 날짜 데이터 생성
        for day in range {
            // day-1일을 더해서 해당 날짜 생성
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfFirstDay) {
                days.append(DateValue(day: day, date: date))
            }
        }
        return days
    }

}
