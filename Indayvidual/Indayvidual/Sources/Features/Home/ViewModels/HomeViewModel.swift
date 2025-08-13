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
    @Published var showCreateScheduleSheet = false
    @Published var showColorPickerSheet = false
    @Published var createScheduleSheetViewModel: CreateScheduleSheetViewModel?
    @Published var filteredSchedules: [ScheduleItem] = []  // 선택된 날짜의 필터링된 일정 (UI 업데이트용)
    
    private var cancellables = Set<AnyCancellable>()   // Combine 구독을 관리하기 위한 프로퍼티
    private var schedules: [ScheduleItem] = []  // 일정 저장 리스트
    
    let calendarProvider = MoyaProvider<CalendarTarget>()
    let evnetProvider = MoyaProvider<EventTarget>()
    private var alertService: AlertService?
    
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
                        let decoded = try JSONDecoder().decode(CustomCalendarResponseDto.self, from: response.data)
                        if decoded.isSuccess {
                            print("✅ 캘린더 조회 성공: \(decoded.data.count)개의 날짜 데이터")
                        } else {
                            print("⚠️ 캘린더 조회 실패: \(decoded.message)")
                            print("⚠️ 서버 응답: \(String(data: response.data, encoding: .utf8) ?? "")")
                            self.alertService?.showAlert(
                                message: "캘린더 정보를 가져오는데 실패했습니다: \(decoded.message)",
                                primaryButton: .primary(title: "재시도", action: { self.fetchHomeCalendar(year: year, month: month, calendarViewModel: calendarViewModel) }),
                                secondaryButton: .secondary(title: "취소", action: {})
                            )
                            return
                        }
                        
                        // UI 업데이트
                        calendarViewModel.clearAllMarkers()
                        for item in decoded.data {
                            if let date = item.date.toDate() {
                                let markerDate = Calendar.current.startOfDay(for: date)
                                for hexColor in item.colors {
                                    if let color = Color(hex: hexColor) {
                                        calendarViewModel.addMarker(for: markerDate, color: color)
                                    }
                                }
                            }
                        }
                    } catch {
                        print("⚠️ 캘린더 데이터 처리 오류: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    print("⚠️ 네트워크 오류(캘린더 조회): \(error.localizedDescription)")
                    self.alertService?.showAlert(
                        message: "네트워크 연결을 확인해주세요.",
                        primaryButton: .primary(title: "재시도", action: { self.fetchHomeCalendar(year: year, month: month, calendarViewModel: calendarViewModel) }),
                        secondaryButton: .secondary(title: "취소", action: {})
                    )
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
                        if apiResponse.isSuccess {
                            print("✅ 일정 조회 성공: \(apiResponse.data.count)개의 이벤트")
                        } else {
                            print("⚠️ 일정 조회 실패: \(apiResponse.message)")
                            print("⚠️ 서버 응답 데이터: \(apiResponse.data)")
                            self.alertService?.showAlert(
                                message: "일정 정보를 가져오는데 실패했습니다: \(apiResponse.message)",
                                primaryButton: .primary(title: "재시도", action: { self.fetchSchedules(for: date) }),
                                secondaryButton: .secondary(title: "취소", action: {})
                            )
                            return
                        }
                        
                        let newSchedules = apiResponse.data.compactMap { dto -> ScheduleItem? in
                            let startTime = dto.startTime?.toFullDate(on: date)
                            let endTime = dto.endTime?.toFullDate(on: date)
                            guard let color = Color(hex: dto.color) else { return nil }
                            return ScheduleItem(id: dto.eventId, startTime: startTime, endTime: endTime, title: dto.title, color: color, isAllDay: dto.isAllDay)
                        }
                        
                        self.schedules = newSchedules
                        self.updateFilteredSchedules(for: date)
                        
                    } catch {
                        print("⚠️ 일정 데이터 처리 오류: \(error.localizedDescription)")
                        self.schedules = []
                        self.updateFilteredSchedules(for: date)
                    }
                case .failure(let error):
                    print("⚠️ 네트워크 오류(일정 조회): \(error.localizedDescription)")
                    self.alertService?.showAlert(
                        message: "네트워크 연결을 확인해주세요.",
                        primaryButton: .primary(title: "재시도", action: { self.fetchSchedules(for: date) }),
                        secondaryButton: .secondary(title: "취소", action: {})
                    )
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
                        print("✅ 일정 삭제 성공: \(schedule.id)")
                        self.handleScheduleDeletion(schedule, calendarViewModel: calendarViewModel)
                    } else {
                        print("⚠️ 일정 삭제 실패 - 상태 코드: \(response.statusCode)")
                        self.alertService?.showAlert(
                            message: "일정 삭제에 실패했습니다. (코드: \(response.statusCode))",
                            primaryButton: .primary(title: "재시도", action: { self.deleteSchedule(schedule, calendarViewModel: calendarViewModel) }),
                            secondaryButton: .secondary(title: "취소", action: {})
                        )
                    }
                case .failure(let error):
                    print("⚠️ 네트워크 오류(일정 삭제): \(error.localizedDescription)")
                    self.alertService?.showAlert(
                        message: "네트워크 연결을 확인해주세요.",
                        primaryButton: .primary(title: "재시도", action: { self.deleteSchedule(schedule, calendarViewModel: calendarViewModel) }),
                        secondaryButton: .secondary(title: "취소", action: {})
                    )
                }
            }
        }
    }
    
    // MARK: - 로컬 데이터 및 UI 업데이트
    func updateFilteredSchedules(for selectedDate: Date) {
        filteredSchedules = schedules.filter { schedule in
            if schedule.isAllDay { return true }
            guard let start = schedule.startTime else { return false }
            return Calendar.current.isDate(start, inSameDayAs: selectedDate)
        }.sorted()
        print("📅 UI 일정 업데이트 완료 (\(filteredSchedules.count)개)")
    }
    
    func addSchedule(_ schedule: ScheduleItem, calendarViewModel: CustomCalendarViewModel) {
        print("➕ 일정 추가: \(schedule.title)")
        schedules.append(schedule)
        schedules.sort()
        if let start = schedule.startTime {
            let markerDate = Calendar.current.startOfDay(for: start)
            calendarViewModel.addMarker(for: markerDate, color: schedule.color)
        }
        updateFilteredSchedules(for: calendarViewModel.selectDate)
    }
    
    func updateSchedule(_ updated: ScheduleItem, from oldSchedule: ScheduleItem, calendarViewModel: CustomCalendarViewModel) {
        print("✏️ 일정 수정: \(oldSchedule.title) → \(updated.title)")
        guard let index = schedules.firstIndex(where: { $0.id == updated.id }) else { return }
        
        if let oldStart = oldSchedule.startTime {
            calendarViewModel.removeMarker(for: Calendar.current.startOfDay(for: oldStart), color: oldSchedule.color)
        }
        if let newStart = updated.startTime {
            calendarViewModel.addMarker(for: Calendar.current.startOfDay(for: newStart), color: updated.color)
        }
        
        schedules[index] = updated
        schedules.sort()
        updateFilteredSchedules(for: calendarViewModel.selectDate)
    }
    
    private func handleScheduleDeletion(_ schedule: ScheduleItem, calendarViewModel: CustomCalendarViewModel) {
        print("🗑️ 로컬 일정 제거: \(schedule.title)")
        schedules.removeAll { $0.id == schedule.id }
        if let start = schedule.startTime {
            calendarViewModel.removeMarker(for: Calendar.current.startOfDay(for: start), color: schedule.color)
        }
        updateFilteredSchedules(for: calendarViewModel.selectDate)
    }
    
    // MARK: - 일정 등록/수정 시트
    func presentScheduleSheet(for schedule: ScheduleItem? = nil, on date: Date, calendarViewModel: CustomCalendarViewModel) {
        guard let alertService = self.alertService else { return }
        
        let sheetViewModel = CreateScheduleSheetViewModel(
            scheduleToEdit: schedule,
            selectedDate: schedule?.startTime ?? date,
            alertService: alertService
        )
        
        sheetViewModel.completionPublisher
            .sink { [weak self] (resultSchedule, isNew) in
                guard let self = self else { return }
                if isNew {
                    self.addSchedule(resultSchedule, calendarViewModel: calendarViewModel)
                } else if let originalSchedule = schedule {
                    self.updateSchedule(resultSchedule, from: originalSchedule, calendarViewModel: calendarViewModel)
                }
                self.showCreateScheduleSheet = false
            }
            .store(in: &cancellables)
        
        self.createScheduleSheetViewModel = sheetViewModel
        self.showCreateScheduleSheet = true
    }
}
