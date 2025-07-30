//
//  CreateScheduleSheetView.swift
//  Indayvidual
//
//  Created by 장주리 on 7/25/25.
//

import SwiftUI
import Combine

struct CreateScheduleSheetView: View {
    @Binding var showColorPickerSheet: Bool
    @Binding var selectedColor: Color
    @Binding var isAllDay: Bool
    @Binding var showEndSection: Bool
    @ObservedObject var calendarVm: CustomCalendarViewModel // HomeView의 ViewModel
    @EnvironmentObject var scheduleVm: ScheduleViewModel

    @Environment(\.dismiss) private var dismiss
    @StateObject private var sheetCalendarVm = CustomCalendarViewModel() // 시트 전용 ViewModel

    @State private var title: String = ""
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()

    private var isPrimaryButtonEnabled: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    let scheduleToEdit: ScheduleItem? // 등록이면 nil

    var body: some View {
        CustomActionSheet(
            title: scheduleToEdit == nil ? "일정 등록" : "일정 수정",
            titleIcon: "calendar_icon",
            primaryButtonTitle: scheduleToEdit == nil ? "일정 등록하기" : "일정 수정하기",
            secondaryButtonTitle: "취소",
            primaryAction: {
                guard isPrimaryButtonEnabled else { return }
                let finalEndTime: Date? = {
                    if isAllDay { return nil } // 하루 종일이면 종료 시간 없음
                    return showEndSection ? endTime : nil // "종료"가 활성화된 경우에만 값 전달
                }()

                // 일정 등록/수정 처리
                scheduleVm.submitSchedule(
                    existingSchedule: scheduleToEdit,
                    title: title,
                    startTime: startTime,
                    endTime: finalEndTime,
                    color: selectedColor,
                    isAllDay: isAllDay,
                    calendarViewModel: calendarVm
                )
                dismiss()
            },
            secondaryAction: {
                dismiss()
            },
            primaryButtonColor: isPrimaryButtonEnabled ? .gray900 : .gray100,
            primaryButtonTextColor: .white,
            secondaryButtonColor: .white,
            secondaryButtonTextColor: .black,
            secondaryButtonBorderColor: .gray200,
            buttonHeight: 55,
            headerRightButton: {
                AnyView(
                    ColorButton(
                        showColorPickerSheet: $showColorPickerSheet,
                        selectedColor: $selectedColor
                    )
                )
            }
        ) { // CustomActionSheet의 content 클로저 시작
            ScrollView {
                VStack(alignment: .center, spacing: 0) {
                    CustomCalendarView(calendarViewModel: sheetCalendarVm,
                                       showToggleButton: false,
                                       showShadow: false,
                                       showNavigationButtons: false,
                                       showMarkers: false,
                                       initialMode: .week)

                    Divider()
                        .padding(.horizontal, 15.4)
                        .padding(.bottom, 20)

                    HStack(spacing: 8) {
                        Image("calendar_icon")
                            .resizable()
                            .frame(width: 22.62, height: 22.62)
                        Text("일정 입력")
                            .font(.pretendSemiBold17)
                        Spacer()
                    }
                    .padding(.horizontal, 15.4)
                    .padding(.bottom, 15)

                    ScheduleInput(
                        title: $title,
                        selectedStartTime: $startTime,
                        selectedEndTime: $endTime,
                        showEndSection: $showEndSection,
                        isAllDay: $isAllDay
                    )
                    .padding(.horizontal, 20)
                    .animation(.easeInOut, value: isAllDay)
                    .animation(.easeInOut, value: showEndSection)

                    Divider()
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                        .padding(.horizontal, 15.4)
                }
            }
        }

        .onAppear {
            // 뷰가 나타날 때 상태 초기화 (등록/수정 모두)
            let (initialTitle, initialStart, initialEnd, initialAllDay, initialShowEnd, initialColor) =
                scheduleVm.initializeInput(for: scheduleToEdit, on: calendarVm.selectDate)

            title = initialTitle
            startTime = initialStart
            endTime = initialEnd
            isAllDay = initialAllDay
            showEndSection = initialShowEnd
            selectedColor = initialColor
            
            // 시트 캘린더의 날짜를 동기화
            sheetCalendarVm.selectDate = calendarVm.selectDate
        }

        .onReceive(sheetCalendarVm.$selectDate) { newDate in
            // 시트 캘린더의 날짜가 변경되면 startTime을 업데이트
            let calendar = Calendar.current
            let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: startTime)
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: newDate)
            dateComponents.hour = timeComponents.hour
            dateComponents.minute = timeComponents.minute
            dateComponents.second = timeComponents.second

            if let updatedStartTime = calendar.date(from: dateComponents) {
                startTime = updatedStartTime
                endTime = Calendar.current.date(byAdding: .hour, value: 1, to: updatedStartTime) ?? updatedStartTime
            }
        }

        // ColorPickerSheet 띄우기
        .sheet(isPresented: $showColorPickerSheet) {
            ColorPickerSheetView(
                showColorPickerSheet: $showColorPickerSheet,
                selectedColor: $selectedColor
            )
            .presentationDragIndicator(.visible)
            .presentationDetents([.fraction(0.8)])
        }
    }
}

#Preview {
    CreateScheduleSheetView(
        showColorPickerSheet: .constant(false),
        selectedColor: .constant(.button),
        isAllDay: .constant(false),
        showEndSection: .constant(true),
        calendarVm: CustomCalendarViewModel(),
        scheduleToEdit: nil // 미리보기는 등록 모드
    )
    .environmentObject(ScheduleViewModel())
}
