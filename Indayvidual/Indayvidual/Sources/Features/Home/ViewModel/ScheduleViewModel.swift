//
//  ScheduleViewModel.swift
//  Indayvidual
//
//  Created by 장주리 on 7/30/25.
//

import Foundation
import SwiftUI
import Combine

class ScheduleViewModel: ObservableObject {
    /// 더미 데이터
    @Published var schedules: [ScheduleItem] = [
        ScheduleItem(
            startTime: Date(), // 현재 시간
            endTime: Date().addingTimeInterval(3600), // 1시간 후
            title: "테스트 일정",
            color: .purple04
        )
    ]
    
    @Published var filteredSchedules: [ScheduleItem] = []
    
    func updateFilteredSchedules(for selectedDate: Date) {
        filteredSchedules = schedules.filter {
            Calendar.current.isDate($0.startTime, inSameDayAs: selectedDate)
        }
        .sorted()
    }
    
    func addSchedule(_ schedule: ScheduleItem) {
        schedules.append(schedule)
        schedules.sort()
    }
    
    func deleteSchedule(_ schedule: ScheduleItem) {
        schedules.removeAll { $0.id == schedule.id }
    }
    
    func updateSchedule(_ updated: ScheduleItem) {
        if let index = schedules.firstIndex(where: { $0.id == updated.id }) {
            schedules[index] = updated
            schedules.sort()
        }
    }
    
    func addNewSchedule(title: String, startTime: Date, endTime: Date?, color: Color, calendarViewModel: CustomCalendarViewModel) {
        let newSchedule = ScheduleItem(startTime: startTime,
                                       endTime: endTime,
                                       title: title,
                                       color: color)
        addSchedule(newSchedule)
        
        /// 캘린더에 해당 일정 마커 반영
        let markerDate = Calendar.current.startOfDay(for: startTime)
        calendarViewModel.addMarker(for: markerDate, color: color)
        
        updateFilteredSchedules(for: calendarViewModel.selectDate)
    }
}
