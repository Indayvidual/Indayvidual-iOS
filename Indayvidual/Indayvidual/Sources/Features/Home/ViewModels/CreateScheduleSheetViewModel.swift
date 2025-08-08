import SwiftUI
import Combine
import Moya

class CreateScheduleSheetViewModel: ObservableObject {
    private let scheduleToEdit: ScheduleItem?
    private var cancellables = Set<AnyCancellable>()
    let completionPublisher = PassthroughSubject<(ScheduleItem, Bool), Never>()
    
    private let eventProvider = MoyaProvider<EventTarget>()
    private var alertService: AlertService?
    
    @Published var title: String = ""
    @Published var startTime: Date = Date()
    @Published var endTime: Date = Date()
    @Published var isAllDay: Bool = false
    @Published var showEndSection: Bool = true
    @Published var selectedColor: Color = .blue
    @Published var showColorPickerSheet: Bool = false
    
    @Published var sheetCalendarVm = CustomCalendarViewModel()
    
    var navigationTitle: String {
        scheduleToEdit == nil ? "일정 등록" : "일정 수정"
    }
    
    var submitButtonTitle: String {
        scheduleToEdit == nil ? "일정 등록하기" : "일정 수정하기"
    }
    
    var isPrimaryButtonEnabled: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - 초기화
    init(
        scheduleToEdit: ScheduleItem?,
        selectedDate: Date,
        alertService: AlertService
    ) {
        self.scheduleToEdit = scheduleToEdit
        self.alertService = alertService
        
        initializeState(with: selectedDate)
        observeSheetCalendarDate()
    }
    
    private func initializeState(with selectedDate: Date) {
        if let schedule = scheduleToEdit {
            // 수정 모드일 때 초기화
            self.title = schedule.title
            self.startTime = schedule.startTime ?? selectedDate
            self.endTime = schedule.endTime ?? self.startTime.addingTimeInterval(3600)
            
            self.isAllDay = schedule.isAllDay
            self.showEndSection = !schedule.isAllDay && (schedule.endTime != nil)
            self.selectedColor = schedule.color
        } else {
            // 새 등록 모드일 때 초기화
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: selectedDate)
            let hour = calendar.component(.hour, from: Date())
            
            self.title = ""
            self.startTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: startOfDay) ?? selectedDate
            self.endTime = self.startTime.addingTimeInterval(3600)
            self.isAllDay = false
            self.showEndSection = true
            self.selectedColor = .button // 기본 색상
        }
        
        self.sheetCalendarVm.selectDate = self.startTime
    }
    
    private func observeSheetCalendarDate() {
        sheetCalendarVm.$selectDate
            .sink { [weak self] newDate in
                self?.updateStartTime(with: newDate)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 일정 등록/수정
    func createSchedule() {
        guard isPrimaryButtonEnabled else { return }
        
        let isNew = scheduleToEdit == nil
        let finalEndTime = calculateFinalEndTime()
        
        if isNew {
            // 생성 요청: 기존 DTO 사용
            let requestDto = createDto(endTime: finalEndTime)
            requestCreate(requestDto: requestDto)
        } else {
            // 수정 요청: 업데이트용 DTO 사용
            let requestDto = updateDto(endTime: finalEndTime)
            requestUpdate(eventId: scheduleToEdit!.id, requestDto: requestDto)
        }
    }
    
    /// 생성 요청 API 호출
    private func requestCreate(requestDto: EventCreateRequestDto) {
        let apiTarget: EventTarget = .postEvent(content: requestDto)
        
        eventProvider.request(apiTarget) { [weak self] result in
            self?.handleResponse(result: result, isNew: true)
        }
    }
    
    /// 수정 요청 API 호출
    private func requestUpdate(eventId: Int, requestDto: EventUpdateRequestDto) {
        let apiTarget: EventTarget = .patchEvent(eventId: eventId, content: requestDto)
        
        eventProvider.request(apiTarget) { [weak self] result in
            self?.handleResponse(result: result, isNew: false)
        }
    }
    
    /// 생성용 DTO 생성
    private func createDto(endTime: Date?) -> EventCreateRequestDto {
        let dateString = startTime.toString(format: "yyyy-MM-dd")
        
        // 하루 종일일 경우 start/endTime nil
        let startTimeString = isAllDay ? nil : startTime.toString(format: "HH:mm")
        let endTimeString = isAllDay ? nil : (endTime?.toString(format: "HH:mm"))
        
        let colorHexString = selectedColor.toHex()
        
        return EventCreateRequestDto(
            date: dateString,
            title: title,
            startTime: startTimeString,
            endTime: endTimeString,
            color: colorHexString,
            isAllDay: isAllDay
        )
    }
    
    /// 수정용 DTO 생성
    private func updateDto(endTime: Date?) -> EventUpdateRequestDto {
        let dateString = startTime.toString(format: "yyyy-MM-dd")
        
        // 하루 종일일 경우 start/endTime nil
        let startTimeString = isAllDay ? nil : startTime.toString(format: "HH:mm")
        let endTimeString = isAllDay ? nil : (endTime?.toString(format: "HH:mm"))
        
        let colorHexString = selectedColor.toHex()
        
        // 수정 DTO는 모든 필드 nullable
        // 빈 문자열이면 nil로 처리하도록 할 수도 있음
        return EventUpdateRequestDto(
            date: dateString.isEmpty ? nil : dateString,
            title: title.isEmpty ? nil : title,
            startTime: startTimeString,
            endTime: endTimeString,
            color: colorHexString,
            isAllDay: isAllDay
        )
    }
    
    /// API 응답 처리 공통 함수
    private func handleResponse(result: Result<Response, MoyaError>, isNew: Bool) {
        DispatchQueue.main.async {
            switch result {
            case .success(let response):
                guard (200...299).contains(response.statusCode) else {
                    self.alertService?.showAlert(message: "서버에 문제가 발생했습니다. (코드: \(response.statusCode))", primaryButton: .primary(title: "확인"))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(APIResponseDto<EventCreateResponseDto>.self, from: response.data)
                    let newEventId = response.data.eventId
                    
                    let finalSchedule = ScheduleItem(
                        id: newEventId,
                        startTime: self.startTime,
                        endTime: self.calculateFinalEndTime(),
                        title: self.title,
                        color: self.selectedColor,
                        isAllDay: self.isAllDay
                    )
                    self.completionPublisher.send((finalSchedule, isNew))
                    
                } catch {
                    self.alertService?.showAlert(message: "데이터 처리 중 오류가 발생했습니다.", primaryButton: .primary(title: "확인"))
                }
                
            case .failure:
                self.alertService?.showAlert(message: "네트워크 연결을 확인해주세요.", primaryButton: .primary(title: "확인"))
            }
        }
    }
    // MARK: - 헬퍼 메서드
    
    private func updateStartTime(with newDate: Date) {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: newDate)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        
        if let updatedStartTime = calendar.date(from: dateComponents) {
            self.startTime = updatedStartTime
            if self.endTime < updatedStartTime {
                self.endTime = calendar.date(byAdding: .hour, value: 1, to: updatedStartTime) ?? updatedStartTime
            }
        }
    }
    
    /// 종료 시간 계산
    private func calculateFinalEndTime() -> Date? {
        if isAllDay { return nil }  // 하루종일 일 경우 종료시간 nil
        return showEndSection ? endTime : nil  // 종료 시간 선택한 경우 endTime, 아닌경우 nil
    }
}
