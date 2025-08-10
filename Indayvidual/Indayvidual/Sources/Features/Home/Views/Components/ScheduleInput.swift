//
//  ScheduleInput.swift
//  Indayvidual
//
//  Created by 장주리 on 7/25/25.
//

import SwiftUI
import UIKit

struct ScheduleInput: View {
    @EnvironmentObject var homeVm: HomeViewModel
    @Environment(\.presentationMode) var presentationMode

    @Binding var title: String
    @Binding var selectedStartTime: Date
    @Binding var selectedEndTime: Date
    @Binding var showEndSection: Bool // 종료 시간 토글 상태
    @Binding var isAllDay: Bool // 하루 종일 토글 상태
    
    @State private var showStartTimePicker: Bool = false
    @State private var showEndTimePicker: Bool = false
    
    private let scheduleInputVm = ScheduleInputViewModel()

    var body: some View {
        VStack(spacing: 20) {
            TextFieldView(searchText: $title)

            Divider()
                .padding(.bottom, 10)

            if !isAllDay {  // 하루 종일이 아닐 경우에만 표시
                TimePickerSectionView(
                    title: "시작",
                    selectedTime: $selectedStartTime,
                    isTimePickerVisible: $showStartTimePicker,
                    togglePicker: { scheduleInputVm.toggleStartTimePicker(showStart: $showStartTimePicker, showEnd: $showEndTimePicker) }
                )

                if showEndSection {   // 종료시간 토글이 ON일 경우에만 표시
                    TimePickerSectionView(
                        title: "종료",
                        selectedTime: $selectedEndTime,
                        isTimePickerVisible: $showEndTimePicker,
                        togglePicker: { scheduleInputVm.toggleEndTimePicker(showStart: $showStartTimePicker, showEnd: $showEndTimePicker) }
                    )
                }
            }

            TimeToggle(
                showEndSection: $showEndSection,
                isAllDay: $isAllDay
            )

        }
        .onChange(of: isAllDay, initial: false) { oldValue, newValue in
            if newValue {
                showEndSection = false
            }
        }
    }

    /// 일정 입력 텍스트 뷰
    struct TextFieldView: View {
        @Binding var searchText: String

        var body: some View {
            TextField("일정을 입력하세요", text: $searchText)
                .font(.pretendMedium14)
                .foregroundColor(.black)
                .disableAutocorrection(true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 15)
                .frame(width: 335, height: 48)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .inset(by: 0.5)
                        .stroke(Color(red: 0.84, green: 0.85, blue: 0.86), lineWidth: 1)
                )
        }
    }

    /// 시간 선택 뷰
    struct TimePickerSectionView: View {
        let title: String
        @Binding var selectedTime: Date
        @Binding var isTimePickerVisible: Bool
        let togglePicker: () -> Void

        var body: some View {
            VStack {
                HStack {
                    Text(title)
                        .font(.pretendMedium14)
                        .foregroundColor(Color.gray700)

                    Spacer()

                    Button {
                        withAnimation { togglePicker() }
                    } label: {
                        HStack(spacing: 4) {
                            Text(formattedTime(selectedTime))
                                .font(.pretendRegular15)
                                .foregroundColor(.gray900)
                        }
                        .padding(.horizontal, 15)
                        .frame(width: 100, height: 33)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                
                
                /// 타임피커
                if isTimePickerVisible {
                    DatePicker("", selection: $selectedTime, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(width: 335, height: 100)
                        .padding(.vertical, 60)
                        .background(Color.gray.opacity(0.1))
                        .transition(.opacity)
                }
            }
        }

        private func formattedTime(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "a h:mm"
            return formatter.string(from: date)
        }
    }

    /// 종료 시간, 하루종일 토글 뷰
    struct TimeToggle: View {
        @Binding var showEndSection: Bool
        @Binding var isAllDay: Bool

        var body: some View {
            VStack(spacing: 20) {
                Toggle("종료 시간", isOn: $showEndSection)
                    .toggleStyle(SwitchToggleStyle(tint: .button))
                    .font(.pretendMedium14)
                    .disabled(isAllDay) // 하루 종일일 때 비활성화

                Toggle("하루 종일", isOn: $isAllDay)
                    .toggleStyle(SwitchToggleStyle(tint: .button))
                    .font(.pretendMedium14)
            }
        }
    }
}

#Preview {
    PreviewWrapper()
}

private struct PreviewWrapper: View {
    @State private var title: String = "테스트 일정"
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date().addingTimeInterval(3600) // 1시간 뒤
    @State private var showEndSection: Bool = true
    @State private var isAllDay: Bool = false

    var body: some View {
        ScheduleInput(
            title: $title,
            selectedStartTime: $startTime,
            selectedEndTime: $endTime,
            showEndSection: $showEndSection,
            isAllDay: $isAllDay
        )
        .environmentObject(HomeViewModel())
    }
}
