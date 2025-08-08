import SwiftUI
import Combine

class CreateScheduleSheetViewModel: ObservableObject {
    private let mainCalendarVm: CustomCalendarViewModel
    private let homeVm: HomeViewModel
    private let scheduleToEdit: ScheduleItem?
    private var cancellables = Set<AnyCancellable>()

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

    init(
        mainCalendarVm: CustomCalendarViewModel,
        homeVm: HomeViewModel,
        scheduleToEdit: ScheduleItem?
    ) {
        self.mainCalendarVm = mainCalendarVm
        self.homeVm = homeVm
        self.scheduleToEdit = scheduleToEdit
        
        initializeState()
        observeSheetCalendarDate()
    }

    private func initializeState() {
        let (initialTitle, initialStart, initialEnd, initialAllDay, initialShowEnd, initialColor) =
            homeVm.initializeInput(for: scheduleToEdit, on: mainCalendarVm.selectDate)

        self.title = initialTitle
        self.startTime = initialStart
        self.endTime = initialEnd
        self.isAllDay = initialAllDay
        self.showEndSection = initialShowEnd
        self.selectedColor = initialColor
        
        self.sheetCalendarVm.selectDate = mainCalendarVm.selectDate
    }
    
    private func observeSheetCalendarDate() {
        sheetCalendarVm.$selectDate
            .sink { [weak self] newDate in
                guard let self = self else { return }
                self.updateStartTime(with: newDate)
            }
            .store(in: &cancellables)
    }

    private func updateStartTime(with newDate: Date) {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: startTime)
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: newDate)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        dateComponents.second = timeComponents.second

        if let updatedStartTime = calendar.date(from: dateComponents) {
            self.startTime = updatedStartTime
            if self.endTime < updatedStartTime {
                self.endTime = Calendar.current.date(byAdding: .hour, value: 1, to: updatedStartTime) ?? updatedStartTime
            }
        }
    }

    private func calculateFinalEndTime() -> Date? {
        if isAllDay { return nil }
        return showEndSection ? endTime : nil
    }

    func submitSchedule() {
        guard isPrimaryButtonEnabled else { return }
        let finalEndTime = calculateFinalEndTime()

        homeVm.submitSchedule(
            existingSchedule: scheduleToEdit,
            title: title,
            startTime: startTime,
            endTime: finalEndTime,
            color: selectedColor,
            isAllDay: isAllDay,
            calendarViewModel: mainCalendarVm
        )
    }
}
