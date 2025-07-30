//
//  ScheduleListView.swift
//  Indayvidual
//
//  Created by 장주리 on 7/30/25.
//

import SwiftUI

struct ScheduleListView: View {
    @EnvironmentObject var scheduleVm: ScheduleViewModel
    @ObservedObject var calendarVm: CustomCalendarViewModel
    
    var body: some View {
        List {
            ForEach(scheduleVm.filteredSchedules) { schedule in
                VStack(alignment: .leading){
                    HStack{
                        Circle()
                            .fill(schedule.color)
                            .frame(width: 10, height: 10)
                        
                        Text(
                            schedule.endTime != nil
                            ? "\(schedule.startTime.toTimeString()) - \(schedule.endTime!.toTimeString())"
                            : schedule.startTime.toTimeString()
                        )
                            .font(.pretendMedium11)
                            .foregroundColor(Color(.gray500))

                        Spacer()
                        
                        ScheduleMenu(schedule: schedule, scheduleVm: scheduleVm)
                    }
                    .padding(.horizontal, 15)
                    
                    Spacer().frame(height: 8)
                    
                    HStack{
                        Spacer().frame(width: 17)
                        
                        Text(schedule.title)
                            .font(.pretendRegular15)
                            .foregroundColor(Color(.gray900))
                    }
                }
                .frame(height: 85)
                .frame(maxWidth: .infinity)
                .background(schedule.color.opacity(0.1))
                .cornerRadius(15)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .padding(.horizontal, 18)
                .padding(.vertical, -3)
                
            }
            .onDelete { indexSet in
                            indexSet.forEach { index in
                                let schedule = scheduleVm.filteredSchedules[index]
                                scheduleVm.deleteSchedule(schedule)
                            }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden) // 리스트 전체 배경 투명
        .background(Color(.gray50).ignoresSafeArea())

    }
}

#Preview {
    let scheduleVm = ScheduleViewModel()
    let calendarVm = CustomCalendarViewModel()
    
    ScheduleListView(calendarVm: calendarVm)
        .environmentObject(scheduleVm)
}
