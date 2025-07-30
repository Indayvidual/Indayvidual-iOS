//
//  ScheduleMenu.swift
//  Indayvidual
//
//  Created by 장주리 on 7/30/25.
//

import SwiftUI

struct ScheduleMenu: View {
    let schedule: ScheduleItem
    @ObservedObject var scheduleVm: ScheduleViewModel
    
    var body: some View {
        Menu {
            Button("수정하기", action: editAction)
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
    
    private func editAction() {
        // TODO: 수정 로직 구현
    }
    
    private func deleteAction() {
        scheduleVm.deleteSchedule(schedule)
    }
}

