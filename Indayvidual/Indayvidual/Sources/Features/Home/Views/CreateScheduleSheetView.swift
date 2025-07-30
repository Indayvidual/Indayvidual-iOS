
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

    // 시작 시간과 종료 시간
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()

    private var isPrimaryButtonEnabled: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        CustomActionSheet(
            title: "일정 등록",
            titleIcon: "calendar_icon",
            primaryButtonTitle: "일정 등록하기",
            secondaryButtonTitle: "취소",
            primaryAction: {
                guard isPrimaryButtonEnabled else { return }
                // isAllDay이면 endTime nil, showEndSection이 true면 endTime, 아니면 nil
                let finalEndTime: Date? = {
                    if isAllDay { return nil }
                    else if showEndSection { return endTime }
                    else { return nil }
                }()
                
                scheduleVm.addNewSchedule(
                    title: title,
                    startTime: startTime,
                    endTime: finalEndTime,
                    color: selectedColor,
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
                    // 시트 전용 ViewModel 사용
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
        .task {
            // 시트 캘린더 날짜 동기화
            sheetCalendarVm.selectDate = calendarVm.selectDate

            // 선택된 날짜 기준으로 오전 9시 시작 시간 세팅
            startTime = Calendar.current.date(
                bySettingHour: 9, minute: 0, second: 0, of: calendarVm.selectDate
            ) ?? Date()

            // 선택된 날짜 기준으로 오후 9시 종료 시간 세팅
            endTime = Calendar.current.date(
                bySettingHour: 21, minute: 0, second: 0, of: calendarVm.selectDate
            ) ?? startTime
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
        calendarVm: CustomCalendarViewModel()
    )
    .environmentObject(ScheduleViewModel())
}
