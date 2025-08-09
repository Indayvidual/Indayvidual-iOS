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
    
    init(initialMode: CalendarMode = .month) {
        self.calendarMode = initialMode
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
        
        if var markers = dateMarkers[dayKey] {
            // 주어진 색상과 일치하는 첫 번째 마커를 찾아 제거
            if let index = markers.firstIndex(where: { $0.color == color }) {
                markers.remove(at: index)
                
                // 마커 배열이 비어있으면 딕셔너리에서 키를 제거
                if markers.isEmpty {
                    dateMarkers.removeValue(forKey: dayKey)
                } else {
                    dateMarkers[dayKey] = markers
                }
            }
        }
    }
    
    /// 모든 마커를 제거합니다. (월 이동 시 호출)
    func clearAllMarkers() {
        dateMarkers.removeAll()
    }
    
    // MARK: - 캘린더 UI 및 날짜 계산 로직
    
    /// 연, 월 문자열 반환
    func getYearAndMonthString(currentDate: Date) -> [String] {
        return currentDate.toString(format: "yyyy.M").split(separator: ".").map { String($0) }
    }
    
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
        
        selectDate = startOfDay
        checkingDate = startOfDay
        popupDate = true
        
        let selectedComponents = calendar.dateComponents([.year, .month], from: startOfDay)
        let displayedComponents = calendar.dateComponents([.year, .month], from: displayedMonthDate)
        
        if selectedComponents.year != displayedComponents.year || selectedComponents.month != displayedComponents.month {
            if let newDisplayedDate = calendar.date(from: selectedComponents) {
                displayedMonthDate = newDisplayedDate
            }
        }
    }
    
    // 월 기준 날짜 배열 생성
    func extractDate(baseDate: Date) -> [DateValue] {
        /// baseDate에서 연,월 정보만 가져와 1일 0시 기준 날짜 생성
        guard let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: baseDate)) else {
            return []
        }
        
        /// 첫날 자정으로 보정 (시간까지 00:00:00)
        let startOfFirstDay = firstOfMonth.startOfDay
        
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
    
}
