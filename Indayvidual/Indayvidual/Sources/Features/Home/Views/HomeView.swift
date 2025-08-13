//
//  HomeView.swift
//  Indayvidual
//
//  Created by 장주리 on 7/25/25.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var calendarVm: CustomCalendarViewModel
    
    @StateObject private var colorVm = ColorViewModel()
    @StateObject private var homeVm = HomeViewModel()
    
    @State private var selectedColor: Color = .button
    @State private var isAllDay: Bool = false
    @State private var showEndSection: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var alertService: AlertService
    
    var body: some View {
        VStack {
            Topbar()
            
            Group{
                CustomCalendarView(
                    calendarViewModel: calendarVm,
                    enableSwipe: true
                )
                .padding(.vertical, 18)
                .onChange(of: calendarVm.selectDate) { _, newDate in
                                   homeVm.fetchSchedules(for: newDate)
                }
                
                if(homeVm.filteredSchedules.isEmpty){
                    EmptyScheduleView()
                }else{
                    ScheduleListView(calendarVm: calendarVm, onEditSchedule: { schedule in
                        homeVm.presentScheduleSheet(
                            for: schedule,
                            on: schedule.startTime ?? calendarVm.selectDate,
                            calendarViewModel: calendarVm
                        )
                    }
                    )
                    
                    .environmentObject(homeVm)
                }
            }
            .padding(.horizontal, 28)
            
            
            
            Spacer()
        }
        .onAppear {
            homeVm.setup(alertService: alertService)
            
            // 기존 필터 업데이트
            homeVm.updateFilteredSchedules(for: calendarVm.selectDate)
            
            // 서버에서 해당 월의 마커 정보 불러오기
            let year = Calendar.current.component(.year, from: calendarVm.selectDate)
            let month = Calendar.current.component(.month, from: calendarVm.selectDate)
            
            homeVm.fetchHomeCalendar(
                year: year,
                month: month,
                calendarViewModel: calendarVm
            )
            
            homeVm.fetchSchedules(for: calendarVm.selectDate)
        }
        
        .onDisappear {
            homeVm.filteredSchedules = []
        }
        .floatingBtn {
            homeVm.presentScheduleSheet(
                on: calendarVm.selectDate,
                calendarViewModel: calendarVm
            )
        }
        
        /// 일정 등록 시트뷰
        .sheet(isPresented: $homeVm.showCreateScheduleSheet) {
            if let sheetViewModel = homeVm.createScheduleSheetViewModel {
                CreateScheduleSheetView(viewModel: sheetViewModel)
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.large])
                    .environmentObject(homeVm)
                    .environmentObject(alertService)
            }
        }
        
        .background(Color(.gray50))
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let calendarVm = CustomCalendarViewModel(initialMode: .month)
        
        return Group {
            HomeView(calendarVm: calendarVm)
                .environmentObject(AlertService())
                .previewDisplayName("iPhone 11")
                .previewDevice("iPhone 11")
            
            HomeView(calendarVm: calendarVm)
                .environmentObject(AlertService())
                .previewDisplayName("iPhone 16 Pro")
                .previewDevice("iPhone 16 Pro")
        }
    }
}
