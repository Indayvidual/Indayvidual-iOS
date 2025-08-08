//
//  CreateScheduleSheetView.swift
//  Indayvidual
//
//  Created by 장주리 on 7/25/25.
//

import SwiftUI
import Combine

struct CreateScheduleSheetView: View {
    @StateObject private var viewModel: CreateScheduleSheetViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: CreateScheduleSheetViewModel) {
           _viewModel = StateObject(wrappedValue: viewModel)
       }

    var body: some View {
        CustomActionSheet(
            title: viewModel.navigationTitle,
            titleIcon: "calendar_icon",
            primaryButtonTitle: viewModel.submitButtonTitle,
            secondaryButtonTitle: "취소",
            primaryAction: {
                viewModel.saveSchedule()
            },
            secondaryAction: {
                dismiss()
            },
            primaryButtonColor: viewModel.isPrimaryButtonEnabled ? .gray900 : .gray100,
            primaryButtonTextColor: .white,
            secondaryButtonColor: .white,
            secondaryButtonTextColor: .black,
            secondaryButtonBorderColor: .gray200,
            buttonHeight: 55,
            headerRightButton: {
                AnyView(
                    ColorButton(
                        showColorPickerSheet: $viewModel.showColorPickerSheet,
                        selectedColor: $viewModel.selectedColor
                    )
                )
            }
        ) {
            ScrollView {
                VStack(alignment: .center, spacing: 0) {
                    CustomCalendarView(
                        calendarViewModel: viewModel.sheetCalendarVm,
                        showToggleButton: false,
                        showShadow: false,
                        showNavigationButtons: false,
                        showMarkers: false,
                        initialMode: .week
                    )

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
                        title: $viewModel.title,
                        selectedStartTime: $viewModel.startTime,
                        selectedEndTime: $viewModel.endTime,
                        showEndSection: $viewModel.showEndSection,
                        isAllDay: $viewModel.isAllDay
                    )
                    .padding(.horizontal, 20)
                    .animation(.easeInOut, value: viewModel.isAllDay)
                    .animation(.easeInOut, value: viewModel.showEndSection)

                    Divider()
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                        .padding(.horizontal, 15.4)
                }
            }
        }
        .sheet(isPresented: $viewModel.showColorPickerSheet) {
            ColorPickerSheetView(
                showColorPickerSheet: $viewModel.showColorPickerSheet,
                selectedColor: $viewModel.selectedColor
            )
            .presentationDragIndicator(.visible)
            .presentationDetents([.fraction(0.8)])
        }
    }
}

#Preview {
    let previewViewModel = CreateScheduleSheetViewModel(
        scheduleToEdit: nil,
        selectedDate: Date(),
        alertService: AlertService()
    )
    
    return CreateScheduleSheetView(viewModel: previewViewModel)
        .environmentObject(AlertService())
}
