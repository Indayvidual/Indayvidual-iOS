//
//  ScheduleInputViewModel.swift
//  Indayvidual
//
//  Created by 장주리 on 7/29/25.
//

import SwiftUI

class ScheduleInputViewModel {
    func toggleStartTimePicker(showStart: Binding<Bool>, showEnd: Binding<Bool>) {
        if showEnd.wrappedValue {
            showEnd.wrappedValue = false
        }
        showStart.wrappedValue.toggle()
    }

    func toggleEndTimePicker(showStart: Binding<Bool>, showEnd: Binding<Bool>) {
        if showStart.wrappedValue {
            showStart.wrappedValue = false
        }
        showEnd.wrappedValue.toggle()
    }

    func handleAllDayChanged(isAllDay: Bool, showEndSection: Binding<Bool>) {
        if isAllDay {
            showEndSection.wrappedValue = false
        }
    }
}
