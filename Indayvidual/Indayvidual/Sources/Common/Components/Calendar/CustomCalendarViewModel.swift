//
//  CustomCalendarViewModel.swift
//  Indayvidual
//
//  Created by 장주리 on 7/8/25.
//

import Foundation
import SwiftUI

/// 캘린더 마커를 위한 구조체. 마커의 색상을 정의
struct Marker: Hashable {
    let color: Color
}

final class CustomCalendarViewModel: ObservableObject {
    @Published var currentDate: Date = Date() // 오늘 날짜
    @Published var selectDate: Date = Date()
    @Published var checkingDate: Date = Date()
    @Published var popupDate: Bool = false
    @Published var calendarMode: CalendarMode = .month
    
    /// 각 날짜에 대한 마커 정보를 저장하는 딕셔너리
    /// 키는 `Date` (년, 월, 일만 고려), 값은 `Marker` 배열
    /// 한 날짜에 최대 3개의 마커를 가질 수 있음
    @Published var dateMarkers: [Date: [Marker]] = [:]

    /// 월 기준 날짜 (year, month 만 있는 Date, 시간은 00:00:00)
    @Published var displayedMonthDate: Date = {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        return calendar.date(from: components) ?? Date()
    }()
    
    init() {
        fetchMarkedDates() //마커 초기화
    }
    
    private func fetchMarkedDates() {
            //임시 더미 데이터 생성 (추후 일정 조회 API 호출로 변경예정)
            addMarker(for: Date(), color: .green)
    
        }

    /// 특정 날짜에 마커를 추가
    /// - Parameters:
    ///   - date: 마커를 추가할 날짜. 시간 정보는 무시하고 년, 월, 일만 사용됩니다.
    ///   - color: 마커의 색상.
    ///
    /// 이 함수는 주어진 날짜에 새로운 마커를 추가
    /// 한 날짜에 최대 3개의 마커만 추가할 수 있으며, 이미 3개의 마커가 있는 경우 가장 오래된 마커가 제거되고 새로운 마커가 추가됨
    func addMarker(for date: Date, color: Color) {
        let calendar = Calendar.current
        let dayKey = calendar.startOfDay(for: date) // 시간 정보를 제거하여 년, 월, 일만 기준으로 사용

        var markers = dateMarkers[dayKey] ?? []
        let newMarker = Marker(color: color)

        if markers.count >= 3 {
            // 3개 이상이면 가장 오래된(첫 번째) 마커를 제거하고 새 마커 추가
            markers.removeFirst()
        }
        markers.append(newMarker)
        dateMarkers[dayKey] = markers
    }

    /// 연, 월 문자열 반환
    func getYearAndMonthString(currentDate: Date) -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.M"
        let components = formatter.string(from: currentDate).split(separator: ".")
        return components.map { String($0) }
    }

    /// 날짜 비교 (년,월,일만 비교)
    func isSameDay(date1: Date, date2: Date) -> Bool {
        Calendar.current.isDate(date1, equalTo: date2, toGranularity: .day)
    }

    /// 월 이동
    func moveMonth(by value: Int) {
        let calendar = Calendar.current

        if let newMonthDate = calendar.date(byAdding: .month, value: value, to: displayedMonthDate) {
            displayedMonthDate = calendar.startOfDay(for: newMonthDate)
        }

        if let newSelectedDate = calendar.date(byAdding: .month, value: value, to: selectDate) {
            selectDate = calendar.startOfDay(for: newSelectedDate)
        }
    }

    /// 주 단위 이동 (selectDate만)
    func moveWeek(byWeeks value: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: value * 7, to: selectDate) {
            updateSelectedDate(newDate)
        }
    }

    /// 캘린더 모드에 따라 이동
    func moveCalendar(by value: Int) {
        switch calendarMode {
        case .month:
            moveMonth(by: value)
        case .week:
            moveWeek(byWeeks: value)
        }
    }

    /// 모드 전환
    func toggleCalendarMode() {
        calendarMode = (calendarMode == .month) ? .week : .month
    }

    //// 날짜 선택 및 월 동기화
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
        
        /// baseDate에서 연,월 정보만 가져와 1일 0시 기준 날짜 생성
        guard let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: baseDate)) else {
            return []
        }
        
        /// 첫날 자정으로 보정 (시간까지 00:00:00)
        let startOfFirstDay = calendar.startOfDay(for: firstOfMonth)
        
        var days: [DateValue] = []
        
        /// 첫날의 요일 (1=일요일, 7=토요일)
        let firstWeekday = calendar.component(.weekday, from: startOfFirstDay)
        
        /// 월 달력 앞 공백 처리 (첫 요일 전까지)
        for _ in 1..<firstWeekday {
            days.append(DateValue(day: -1, date: .distantPast))
        }
        
        /// 해당 월의 전체 일 수 (예: 31일)
        guard let range = calendar.range(of: .day, in: .month, for: startOfFirstDay) else {
            return []
        }
        
        /// 날짜 데이터 생성
        for day in range {
            /// day-1일을 더해서 해당 날짜 생성
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfFirstDay) {
                days.append(DateValue(day: day, date: date))
            }
        }
        return days
    }
    
    /// 날짜 변환 유틸
    func dateFromYMD(year: Int, month: Int, day: Int) -> Date {
        if let date = Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) {
            return date
        } else {
            // 실패 시 처리: 로그 찍기 등
            print("⚠️ 날짜 변환 실패: \(year)-\(month)-\(day)")
            return Date()
        }
    }

}
