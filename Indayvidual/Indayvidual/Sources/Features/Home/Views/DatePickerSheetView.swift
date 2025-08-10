//
//  DatePickerSheetView.swift
//  Indayvidual
//
//  Created by 장주리 on 7/25/25.
//

import SwiftUI

struct DatePickerSheetView: View {
    @Binding var showColorPickerSheet: Bool
    @Binding var selectedColor: Color
        
    @ObservedObject var calendarVm: CustomCalendarViewModel
    
    var onComplete: (Date) -> Void
    
    @Environment(\.dismiss) private var dismiss
    

    var body: some View {
        CustomActionSheet(
            title: "일정 등록",
            titleIcon: "calendar_icon",
            primaryButtonTitle: "일정 선택",
            primaryAction: {
                onComplete(calendarVm.selectDate)
                dismiss()
            },
            secondaryAction: {
                dismiss()
            },
            primaryButtonColor: .gray900,
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
        ) {
            VStack(alignment: .center, spacing: 0) {
                CustomCalendarView(
                    calendarViewModel: calendarVm,
                    showToggleButton: false,
                    showShadow: false,
                    showNavigationButtons: false,
                    showMarkers: false
                )
                                
                Divider()
                    .padding(.bottom, 20)
            }
        }
        // ColorPickerSheet 띄우기
        .sheet(isPresented: $showColorPickerSheet) {
            ColorPickerSheetView(
                showColorPickerSheet: $showColorPickerSheet,
                selectedColor: $selectedColor
            )
            .presentationDragIndicator(.visible)
            .presentationDetents([.fraction(0.95)])
        }
    }
}

#Preview {
    DatePickerSheetView(
        showColorPickerSheet: .constant(false),
        selectedColor: .constant(.green),
        calendarVm: CustomCalendarViewModel(),
        onComplete: { selectedDate in
            print("\(selectedDate) 선택됨")
        }
    )
}
