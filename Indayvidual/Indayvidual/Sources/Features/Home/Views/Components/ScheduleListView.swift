//
//  ScheduleListView.swift
//  Indayvidual
//
//  Created by 장주리 on 7/30/25.
//

import SwiftUI

struct ScheduleListView: View {
    @State private var scheduleToEdit: ScheduleItem? = nil
    
    @EnvironmentObject var homeVm: HomeViewModel
    @ObservedObject var calendarVm: CustomCalendarViewModel
    
    // 수정 버튼 눌렀을 때 호출되는 클로저
    var onEditSchedule: ((ScheduleItem) -> Void)?
    
    var body: some View {
        List {
            ForEach(homeVm.filteredSchedules) { schedule in
                VStack(alignment: .leading){
                    HStack{
                        Circle()
                            .fill(schedule.color)
                            .frame(width: 10, height: 10)
                        
                        Text(schedule.isAllDay ? "하루 종일" : schedule.timeText)
                            .font(.pretendMedium11)
                            .foregroundColor(Color(.gray500))
                        
                        Spacer()
                        
                        ScheduleMenu(
                            schedule: schedule,
                            homeVm: homeVm,
                            calendarVm: calendarVm,
                            onEdit: {
                                onEditSchedule?(schedule)
                            }
                        )
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
                .listRowInsets(EdgeInsets(top: 7, leading: 0, bottom: 7, trailing: 0))
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        homeVm.deleteSchedule(schedule, calendarViewModel: calendarVm)
                    } label: {
                        Image(systemName: "trash.fill")
                    }
                    .tint(.red)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden) // 리스트 전체 배경 투명
        .background(Color(.gray50).ignoresSafeArea())
        
    }
}

#Preview {
    let previewView: some View = {
        let homeVm = HomeViewModel()
        let calendarVm = CustomCalendarViewModel()
        
        homeVm.filteredSchedules = [
            ScheduleItem(
                id: 1,
                startTime: Date(),
                endTime: Date(),
                title: "팀 프로젝트 회의",
                color: .blue,
                isAllDay: false
            ),
            ScheduleItem(
                id: 2,
                startTime: Date(),
                endTime: Date(),
                title: "헬스장 운동",
                color: .green,
                isAllDay: true
                
            )
        ]
        
        return ScheduleListView(calendarVm: calendarVm) { schedule in
            print("편집: \(schedule.title)")
        }
        .environmentObject(homeVm)
    }()
    
    previewView
}
