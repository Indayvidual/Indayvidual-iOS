//
//  HomeView.swift
//  Indayvidual
//
//  Created by 장주리 on 7/25/25.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var calendarVm: CustomCalendarViewModel
    @StateObject private var scheduleVm = ScheduleViewModel()
    @StateObject private var colorVm = ColorViewModel()
    @StateObject private var homeVm = HomeViewModel()
    
    @State private var selectedColor: Color = .button
    @State private var isAllDay: Bool = false
    @State private var showEndSection: Bool = false

    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Topbar()
            
            CustomCalendarView(calendarViewModel: calendarVm)
                .onChange(of: calendarVm.selectDate) { oldDate, newDate in
                    scheduleVm.updateFilteredSchedules(for: newDate)
                }
            
            Spacer().frame(height: 33)
            
            ScheduleListView(calendarVm: calendarVm)
                .environmentObject(scheduleVm)
            
            Spacer()
        }
        .onAppear {
            scheduleVm.updateFilteredSchedules(for: calendarVm.selectDate)
        }
        
        .onDisappear {
            scheduleVm.filteredSchedules = []
        }
        .floatingBtn {
            homeVm.showDatePickerSheet.toggle()
        }
        /// 일정 선택 시트뷰
        .sheet(isPresented: $homeVm.showDatePickerSheet) {
            DatePickerSheetView(
                showCreateScheduleSheet: $homeVm.showCreateScheduleSheet,
                showColorPickerSheet: $homeVm.showColorPickerSheet,
                selectedColor: $selectedColor,
                calendarVm: calendarVm
            )
            .presentationDragIndicator(.visible)
            .presentationDetents([.fraction(0.65)])
        }
        
        /// 일정 등록 시트뷰
        .sheet(isPresented: $homeVm.showCreateScheduleSheet) {
            CreateScheduleSheetView(
                showColorPickerSheet: $homeVm.showColorPickerSheet,
                selectedColor: $selectedColor,
                isAllDay: $isAllDay,
                showEndSection: $showEndSection,
                calendarVm: calendarVm
            )
            .presentationDragIndicator(.visible)
            .presentationDetents([.fraction(0.83), .large])
            .environmentObject(scheduleVm)
        }
        
        .background(Color(.gray50))
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let calendarVm = CustomCalendarViewModel(initialMode: .month)
        
        return Group {
            HomeView(calendarVm: calendarVm)
                .previewDisplayName("iPhone 11")
                .previewDevice("iPhone 11")
            
            HomeView(calendarVm: calendarVm)
                .previewDisplayName("iPhone 16 Pro")
                .previewDevice("iPhone 16 Pro")
        }
    }
}
