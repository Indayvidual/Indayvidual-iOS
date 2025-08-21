//
//  ScheduleMenu.swift
//  Indayvidual
//
//  Created by 장주리 on 7/30/25.
//

import SwiftUI

struct ScheduleMenu: View {
    let schedule: ScheduleItem
    var homeVm: HomeViewModel
    var calendarVm: CustomCalendarViewModel 
    var onEdit: (() -> Void)? = nil
    
    
    var body: some View {
        Menu {
            Button("수정하기") {
                onEdit?()
            }
            Button(role: .destructive, action: deleteAction) {
                Text("삭제하기")
            }
        } label: {
            Image("more-btn-gray")
                .frame(width: 13, height: 3)
                .foregroundColor(.white)
                .padding(.vertical, 4)
        }
    }

    private func deleteAction() {
        homeVm.deleteSchedule(schedule, calendarViewModel: calendarVm)
    }
}

