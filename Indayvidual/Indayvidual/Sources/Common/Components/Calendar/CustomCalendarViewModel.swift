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
    private let calendar = Calendar.current  //Calendar.current를 반복적으로 호출하는 것을 방지하기 위해 프로퍼티로 선언
    
    @Published var selectDate: Date = Date()
    @Published var calendarMode: CalendarMode = .month
    
    /// 각 날짜에 대한 마커 정보를 저장하는 딕셔너리
    /// 키는 `Date` (년, 월, 일만 고려), 값은 `Marker` 배열
    /// 한 날짜에 최대 3개의 마커를 가질 수 있음
    @Published var dateMarkers: [Date: [Marker]] = [:]
    
    /// 월 기준 날짜 (1일)
    @Published var displayedMonthDate: Date = {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        return calendar.date(from: components) ?? Date()
    }()
    
    init(initialMode: CalendarMode = .month) {
        self.calendarMode = initialMode
        let now = Date().startOfDay
        self.selectDate = now
        let components = calendar.dateComponents([.year, .month], from: now)
        self.displayedMonthDate = calendar.date(from: components) ?? now
    }
    
    
    // MARK: - 마커 관리
    
    /// 특정 날짜에 마커를 추가
    /// - Parameters:
    ///   - date: 마커를 추가할 날짜. 시간 정보는 무시하고 년, 월, 일만 사용됩니다.
    ///   - color: 마커의 색상.
    ///
    /// 이 함수는 주어진 날짜에 새로운 마커를 추가
    /// 한 날짜에 최대 3개의 마커만 추가할 수 있으며, 이미 3개의 마커가 있는 경우 가장 오래된 마커가 제거되고 새로운 마커가 추가됨
    func addMarker(for date: Date, color: Color) {
        let dayKey = date.startOfDay
        
        var markers = dateMarkers[dayKey] ?? []
        let newMarker = Marker(color: color)
        
        if markers.count >= 3 {
            // 3개 이상이면 가장 오래된(첫 번째) 마커를 제거하고 새 마커 추가
            markers.removeFirst()
        }
        markers.append(newMarker)
        dateMarkers[dayKey] = markers
    }
    
    /// 특정 날짜의 특정 색상 마커를 제거
    func removeMarker(for date: Date, color: Color) {
            let dayKey = date.startOfDay
            
            if let oldMarkers = dateMarkers[dayKey] {
                let newMarkers = oldMarkers.filter { $0.color != color }
                if newMarkers.isEmpty {
                    dateMarkers.removeValue(forKey: dayKey)
                } else {
                    dateMarkers[dayKey] = newMarkers
                }
            }
        }
    
    /// 모든 마커를 제거합니다. (월 이동 시 호출)
    func clearAllMarkers() {
        dateMarkers.removeAll()
    }
    
    // MARK: - 캘린더 UI 및 날짜 계산 로직
    /// 월 이동
    func moveMonth(by value: Int) {
        if let newMonthDate = calendar.date(byAdding: .month, value: value, to: displayedMonthDate) {
            displayedMonthDate = newMonthDate.startOfDay
        }
        
        if let newSelectedDate = calendar.date(byAdding: .month, value: value, to: selectDate) {
            selectDate = newSelectedDate.startOfDay
        }
    }
    
    /// 주 단위 이동 (selectDate만)
    func moveWeek(byWeeks value: Int) {
        if let newDate = calendar.date(byAdding: .day, value: value * 7, to: selectDate) {
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
        let startOfDay = date.startOfDay
        
        // 선택된 날짜가 같으면 무시 (불필요한 뷰 리프레시 방지)
        if selectDate == startOfDay { return }
        
        selectDate = startOfDay
        print("선택 날짜 : \(selectDate)")
        
        // 선택된 날짜의 연월과 현재 표시중인 연월 비교 후 다르면 업데이트
        var selectedComponents = calendar.dateComponents([.year, .month], from: startOfDay)
        selectedComponents.day = 1
        let displayedComponents = calendar.dateComponents([.year, .month], from: displayedMonthDate)
        
        if selectedComponents.year != displayedComponents.year || selectedComponents.month != displayedComponents.month {
            if let newDisplayedDate = calendar.date(from: selectedComponents) {
                displayedMonthDate = newDisplayedDate
            }
        }
    }
    
    // MARK: - 달력 데이터 생성 (리팩토링된 핵심 로직)
    /// 월간 캘린더 그리드를 구성하는 DateValue 배열을 생성합니다.
    /// 이전/현재/다음 달의 날짜를 모두 포함하여 항상 일정한 개수의 배열을 반환합니다.
    func extractDate() -> [DateValue] {
        var days: [DateValue] = []
        
        // 1. 현재 월의 정보 계산
        let firstDay = firstDayOfMonth()
        let firstWeekday = calendar.component(.weekday, from: firstDay) // 1(일) ~ 7(토)
        let daysInMonth = numberOfDays(in: displayedMonthDate)
        
        // 2. 이전 달 날짜 추가 (앞쪽 공백 채우기)
        let leadingDays = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        if leadingDays > 0 {
            // 이전 달의 마지막 날을 계산합니다.
            guard let lastDayOfPreviousMonth = calendar.date(byAdding: .day, value: -1, to: firstDay) else {
                return []
            }
            
            for i in (0..<leadingDays).reversed() {
                if let date = calendar.date(byAdding: .day, value: -i, to: lastDayOfPreviousMonth) {
                    let day = calendar.component(.day, from: date)
                    days.append(DateValue(day: day, date: date, isCurrentMonth: false))
                }
            }
        }
        
        // 3. 현재 달 날짜 추가
        for day in 1...daysInMonth {
            if let date = calendar.date(bySetting: .day, value: day, of: firstDay) {
                days.append(DateValue(day: day, date: date, isCurrentMonth: true))
            }
        }
        
        // 4. 다음 달 날짜 추가 (뒤쪽 공백 채우기)
        let totalDays = 42 // 6주 * 7일 = 42개의 셀을 기준으로 고정
        let remainingDays = totalDays - days.count
        
        if remainingDays > 0 {
            guard let firstDayOfNextMonth = calendar.date(byAdding: .month, value: 1, to: firstDay) else {
                return []
            }
            
            for day in 1...remainingDays {
                if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfNextMonth) {
                    days.append(DateValue(day: day, date: date, isCurrentMonth: false))
                }
            }
        }
        
        return days
    }
    
    // 주 기준 날짜 배열 생성
    func getThisWeekDateValues() -> [DateValue] {
        let calendar = Calendar.current
        let selectedDate = selectDate
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)) else {
            return []
        }
        
        return (0..<7).compactMap { offset in
            if let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek) {
                let day = calendar.component(.day, from: date)
                let isCurrentMonth = calendar.isDate(date, equalTo: displayedMonthDate, toGranularity: .month)
                return DateValue(day: day, date: date, isCurrentMonth: isCurrentMonth)
            }
            return nil
        }
    }
    
    /// 현재 표시중인 월의 첫째 날 `Date`를 반환합니다.
    private func firstDayOfMonth() -> Date {
        let components = calendar.dateComponents([.year, .month], from: displayedMonthDate)
        return calendar.date(from: components) ?? Date()
    }
    
    /// 특정 월에 며칠이 있는지 반환합니다.
    private func numberOfDays(in month: Date) -> Int {
        return calendar.range(of: .day, in: .month, for: month)?.count ?? 0
    }
    
}
