//
//  HomeViewModel.swift
//  Indayvidual
//
//  Created by 장주리 on 7/25/25.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var showDatePickerSheet = false
    @Published var showCreateScheduleSheet = false
    @Published var showColorPickerSheet = false
    
    /// 일정 저장 리스트
    private var schedules: [ScheduleItem] = []
    
    /// 선택된 날짜의 필터링된 일정 (UI 업데이트용)
    @Published var filteredSchedules: [ScheduleItem] = []

    /// 선택된 날짜 기준으로 필터링
    func updateFilteredSchedules(for selectedDate: Date) {
        filteredSchedules = schedules
            .filter { Calendar.current.isDate($0.startTime, inSameDayAs: selectedDate) }
            .sorted()
    }

    /// 일정 추가
    func addSchedule(_ schedule: ScheduleItem) {
        schedules.append(schedule)
        schedules.sort()
    }

    /// 일정 삭제
    func deleteSchedule(_ schedule: ScheduleItem, calendarViewModel: CustomCalendarViewModel) {
        // 1. 데이터 소스에서 일정 제거
        schedules.removeAll { $0.id == schedule.id }
        
        // 2. 캘린더 뷰모델에서 해당 날짜의 마커 제거
        let markerDate = Calendar.current.startOfDay(for: schedule.startTime)
        calendarViewModel.removeMarker(for: markerDate, color: schedule.color)
        
        // 3. 현재 보고 있는 날짜의 일정 목록을 새로고침하여 UI에 반영
        updateFilteredSchedules(for: calendarViewModel.selectDate)
    }

    /// 일정 수정
    func updateSchedule(
        _ updated: ScheduleItem,
        from oldSchedule: ScheduleItem,
        calendarViewModel: CustomCalendarViewModel
    ) {
        if let index = schedules.firstIndex(where: { $0.id == updated.id }) {
            // 1. 이전 날짜의 마커 제거
            let oldMarkerDate = Calendar.current.startOfDay(for: oldSchedule.startTime)
            calendarViewModel.removeMarker(for: oldMarkerDate, color: oldSchedule.color)

            // 2. 새 날짜에 마커 추가
            let newMarkerDate = Calendar.current.startOfDay(for: updated.startTime)
            calendarViewModel.addMarker(for: newMarkerDate, color: updated.color)

            // 3. 일정 데이터 업데이트
            schedules[index] = updated
            schedules.sort()

            // 4. UI 갱신
            updateFilteredSchedules(for: calendarViewModel.selectDate)
        }
    }

    /// 새로운 일정 생성 및 마커 등록
    func addNewSchedule(
        title: String,
        startTime: Date,
        endTime: Date?,
        color: Color,
        isAllDay: Bool,
        calendarViewModel: CustomCalendarViewModel
    ) {
        let newSchedule = ScheduleItem(
            startTime: startTime,
            endTime: endTime,
            title: title,
            color: color,
            isAllDay: isAllDay
        )
        
        addSchedule(newSchedule)
        
        let markerDate = Calendar.current.startOfDay(for: startTime)
        calendarViewModel.addMarker(for: markerDate, color: color)
        
        updateFilteredSchedules(for: calendarViewModel.selectDate)
    }

    /// 입력 초기값 설정
    func initializeInput(for schedule: ScheduleItem?, on date: Date) -> (String, Date, Date, Bool, Bool, Color) {
        if let schedule = schedule {
            // 수정 모드: 기존 데이터 사용
            return (
                schedule.title,
                schedule.startTime,
                schedule.endTime ?? schedule.startTime.addingTimeInterval(3600), // nil이면 1시간 뒤로
                schedule.isAllDay,
                schedule.endTime != nil && !schedule.isAllDay, // 종료 시간 표시 여부
                schedule.color
            )
        } else {
            // 등록 모드: 현재 날짜 기준으로 기본값 설정
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let startTime = calendar.date(bySettingHour: calendar.component(.hour, from: Date()), minute: 0, second: 0, of: startOfDay) ?? date
            let endTime = calendar.date(byAdding: .hour, value: 1, to: startTime) ?? startTime
            return ("", startTime, endTime, false, true, .button)
        }
    }

    func submitSchedule(
        existingSchedule: ScheduleItem?,
        title: String,
        startTime: Date,
        endTime: Date?,
        color: Color,
        isAllDay: Bool,
        calendarViewModel: CustomCalendarViewModel
    ) {
        if let schedule = existingSchedule {
            // 수정
            let updatedSchedule = ScheduleItem(
                id: schedule.id,
                startTime: startTime,
                endTime: endTime,
                title: title,
                color: color,
                isAllDay: isAllDay
            )
            updateSchedule(
                updatedSchedule,
                from: schedule,
                calendarViewModel: calendarViewModel
            )
        } else {
            // 등록
            addNewSchedule(
                title: title,
                startTime: startTime,
                endTime: endTime,
                color: color,
                isAllDay: isAllDay,
                calendarViewModel: calendarViewModel
            )
        }
    }
}