//
//  HomeViewModel.swift
//  Indayvidual
//
//  Created by 장주리 on 7/25/25.
//

import Combine
import Moya
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var showDatePickerSheet = false
    @Published var showCreateScheduleSheet = false
    @Published var showColorPickerSheet = false
    
    @Published var createScheduleSheetViewModel: CreateScheduleSheetViewModel?
    
    @Published var filteredSchedules: [ScheduleItem] = []  // 선택된 날짜의 필터링된 일정 (UI 업데이트용)
    
    private var cancellables = Set<AnyCancellable>()   // Combine 구독을 관리하기 위한 프로퍼티
    private var schedules: [ScheduleItem] = []  // 일정 저장 리스트
    
    let calendarProvider = MoyaProvider<CalendarTarget>()
    let evnetProvider = MoyaProvider<EventTarget>()
    private var alertService: AlertService? // AlertService 주입

    func setup(alertService: AlertService) {
        self.alertService = alertService
    }
    
    // MARK: - 캘린더 조회
    func fetchHomeCalendar(year: Int, month: Int, calendarViewModel: CustomCalendarViewModel) {
        calendarProvider.request(.getHomeCalendar(year: year, month: month)) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    do {
                        let decoded = try JSONDecoder().decode(CustomCalendarResponseDto.self, from: response.data) // 응답 객체
                        
                        guard decoded.isSuccess else {
                            self.alertService?.showAlert(message: "캘린더 정보를 가져오는데 실패했습니다: \(decoded.message)", primaryButton: .primary(title: "재시도", action: { self.fetchHomeCalendar(year: year, month: month, calendarViewModel: calendarViewModel) }), secondaryButton: .secondary(title: "취소", action: {}))
                            return
                        }
                        
                        // 캘린더 UI 업데이트
                        calendarViewModel.clearAllMarkers()
                        for item in decoded.data {
                            if let date = item.date.toDate() {
                                let markerDate = Calendar.current.startOfDay(for: date)
                                for hexColor in item.colors {
                                    calendarViewModel.addMarker(for: markerDate, color: Color(hex: hexColor)!)
                                }
                            }
                        }
                    } catch {
                        self.alertService?.showAlert(message: "캘린더 데이터 처리 중 오류가 발생했습니다.", primaryButton: .primary(title: "재시도", action: { self.fetchHomeCalendar(year: year, month: month, calendarViewModel: calendarViewModel) }), secondaryButton: .secondary(title: "취소", action: {}))
                    }
                case .failure:
                    self.alertService?.showAlert(message: "네트워크 연결을 확인해주세요.", primaryButton: .primary(title: "재시도", action: { self.fetchHomeCalendar(year: year, month: month, calendarViewModel: calendarViewModel) }), secondaryButton: .secondary(title: "취소", action: {}))
                }
            }
        }
    }
    
    // MARK: - 일일 스케줄 조회
    func fetchSchedules(for date: Date) {
        let dateString = date.toString(format: "yyyy-MM-dd")
        
        evnetProvider.request(.getEvents(date: dateString)) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    do {
                        let apiResponse = try JSONDecoder().decode(APIResponseDto<[EventResponseDto]>.self, from: response.data)
                        
                        guard apiResponse.isSuccess else {
                            self.alertService?.showAlert(message: "일정 정보를 가져오는데 실패했습니다: \(apiResponse.message)", primaryButton: .primary(title: "재시도", action: { self.fetchSchedules(for: date) }), secondaryButton: .secondary(title: "취소", action: {}))
                            return
                        }
                        
                        let eventDTOs = apiResponse.data
                        
                        let newSchedules = eventDTOs.compactMap { dto -> ScheduleItem? in
                            let startTime = dto.startTime?.toFullDate(on: date)
                            let endTime = dto.endTime?.toFullDate(on: date)
                            
                            guard let color = Color(hex: dto.color) else {
                                return nil
                            }
                            
                            return ScheduleItem(
                                id: dto.eventId,
                                startTime: startTime,
                                endTime: endTime,
                                title: dto.title,
                                color: color,
                                isAllDay: false
                            )
                        }
                        
                        self.schedules = newSchedules
                        self.updateFilteredSchedules(for: date)
                        
                    } catch {
                        self.alertService?.showAlert(message: "일정 데이터 처리 중 오류가 발생했습니다.", primaryButton: .primary(title: "재시도", action: { self.fetchSchedules(for: date) }), secondaryButton: .secondary(title: "취소", action: {}))
                        self.schedules = []
                        self.updateFilteredSchedules(for: date)
                    }
                    
                case .failure:
                    self.alertService?.showAlert(message: "네트워크 연결을 확인해주세요.", primaryButton: .primary(title: "재시도", action: { self.fetchSchedules(for: date) }), secondaryButton: .secondary(title: "취소", action: {}))
                    self.schedules = []
                    self.updateFilteredSchedules(for: date)
                }
            }
        }
    }
    
    // MARK: - 일정 삭제
    func deleteSchedule(_ schedule: ScheduleItem, calendarViewModel: CustomCalendarViewModel) {
        evnetProvider.request(.deleteEvent(eventId: schedule.id)) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if (200...299).contains(response.statusCode) {
                        self.handleScheduleDeletion(schedule, calendarViewModel: calendarViewModel)
                    } else {
                        self.alertService?.showAlert(message: "일정 삭제에 실패했습니다. (코드: \(response.statusCode))", primaryButton: .primary(title: "재시도", action: { self.deleteSchedule(schedule, calendarViewModel: calendarViewModel) }), secondaryButton: .secondary(title: "취소", action: {}))
                    }
                case .failure:
                    self.alertService?.showAlert(message: "네트워크 연결을 확인해주세요.", primaryButton: .primary(title: "재시도", action: { self.deleteSchedule(schedule, calendarViewModel: calendarViewModel) }), secondaryButton: .secondary(title: "취소", action: {}))
                }
            }
        }
    }


    // MARK: - 로컬 데이터 및 UI 업데이트
    
    /// 로컬 `schedules` 배열과 UI를 동기화합니다.
    func updateFilteredSchedules(for selectedDate: Date) {
        filteredSchedules = schedules
            .filter { schedule in
                guard let start = schedule.startTime else { return false }
                return Calendar.current.isDate(start, inSameDayAs: selectedDate)
            }
            .sorted()
    }
    
    /// 새 일정을 로컬 데이터에 추가하고 UI를 업데이트합니다.
    func addSchedule(_ schedule: ScheduleItem, calendarViewModel: CustomCalendarViewModel) {
        schedules.append(schedule)
        schedules.sort()

        if let start = schedule.startTime {
            let markerDate = Calendar.current.startOfDay(for: start)
            calendarViewModel.addMarker(for: markerDate, color: schedule.color)
        }
        updateFilteredSchedules(for: calendarViewModel.selectDate)
    }

    /// 기존 일정을 업데이트하고 UI를 갱신합니다.
    func updateSchedule(
        _ updated: ScheduleItem,
        from oldSchedule: ScheduleItem,
        calendarViewModel: CustomCalendarViewModel
    ) {
        guard let index = schedules.firstIndex(where: { $0.id == updated.id }) else { return }
        
        // 캘린더 마커 업데이트
        if let oldStart = oldSchedule.startTime {
            let oldMarkerDate = Calendar.current.startOfDay(for: oldStart)
            calendarViewModel.removeMarker(for: oldMarkerDate, color: oldSchedule.color)
        }
        if let newStart = updated.startTime {
            let newMarkerDate = Calendar.current.startOfDay(for: newStart)
            calendarViewModel.addMarker(for: newMarkerDate, color: updated.color)
        }
        
        // 로컬 데이터 업데이트
        schedules[index] = updated
        schedules.sort()
        updateFilteredSchedules(for: calendarViewModel.selectDate)
    }
    
    /// 삭제된 일정을 로컬 데이터에서 제거하고 UI를 업데이트합니다.
    private func handleScheduleDeletion(_ schedule: ScheduleItem, calendarViewModel: CustomCalendarViewModel) {
        schedules.removeAll { $0.id == schedule.id }
        
        if let start = schedule.startTime {
            let markerDate = Calendar.current.startOfDay(for: start)
            calendarViewModel.removeMarker(for: markerDate, color: schedule.color)
        }
        
        updateFilteredSchedules(for: calendarViewModel.selectDate)
    }
    
    // MARK: -일정 등록 또는 수정 sheet를 띄우고 결과 구독
    func presentScheduleSheet(
        for schedule: ScheduleItem? = nil, // 수정할 스케줄. 새 등록 시 nil
        on date: Date,
        calendarViewModel: CustomCalendarViewModel
    ) {
        guard let alertService = self.alertService else { return }
        // 1. 자식 ViewModel 생성
        let sheetViewModel = CreateScheduleSheetViewModel(
            scheduleToEdit: schedule,
            selectedDate: schedule?.startTime ?? date,
            alertService: alertService
        )
        
        // 2. 자식 ViewModel의 Publisher 구독
        sheetViewModel.completionPublisher
            .sink { [weak self] (resultSchedule, isNew) in
                guard let self = self else { return }
                
                // 3. 결과에 따라 분기 처리
                if isNew {
                    self.addSchedule(resultSchedule, calendarViewModel: calendarViewModel)
                } else if let originalSchedule = schedule {
                    self.updateSchedule(
                        resultSchedule,
                        from: originalSchedule,
                        calendarViewModel: calendarViewModel
                    )
                }
                
                // 4. sheet 닫기
                self.showCreateScheduleSheet = false
            }
            .store(in: &cancellables)
        
        // 5. 생성한 자식 ViewModel을 View에 전달하고 sheet 띄우기
        self.createScheduleSheetViewModel = sheetViewModel
        self.showCreateScheduleSheet = true
    }
}
