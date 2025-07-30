//
//  MyHabitViewModel.swift
//  Indayvidual
//
//  Created by 김도연 on 7/23/25.
//

import Foundation
import SwiftUI

@Observable
class MyHabitViewModel {
    // MARK: - 입력 필드
    var title: String
    var colorName: String
    
    // MARK: - 모드 구분
    let isEditing: Bool
    let editIndex: Int?   // 수정 시, sharedVM.habits 에서의 인덱스
    
    // MARK: - 공유 뷰모델 참조
    private let sharedVM: CustomViewModel
    
    init(sharedVM: CustomViewModel, habit: MyHabitModel? = nil, index: Int? = nil) {
        self.sharedVM = sharedVM
        if let habit = habit, let idx = index {
            // 수정 모드
            self.title = habit.title
            self.colorName = habit.colorName
            self.editIndex = idx
            self.isEditing = true
        } else {
            // 신규 작성 모드
            self.title = ""
            self.colorName = "purple-05"
            self.editIndex = nil
            self.isEditing = false
        }
    }
    
    func save() {
        let nowTitle = title.isEmpty ? "습관 이름" : title
        
        if let idx = editIndex {
            // 수정 모드: 해당 인덱스 항목 업데이트 후 맨 앞 이동
            var updated = sharedVM.habits[idx]
            updated.title = title
            updated.colorName = colorName
            sharedVM.habits.remove(at: idx)
            sharedVM.habits.insert(updated, at: 0)
        } else {
            // 신규 모드: 새로운 Habit 생성 후 맨 앞 삽입
            let newHabit = MyHabitModel(
                title: nowTitle,
                colorName: colorName,
                checkedAt: "",
                isSelected: false
            )
            sharedVM.habits.insert(newHabit, at: 0)
        }
    }

    func delete(at index: Int) {
        guard index >= 0 && index < sharedVM.habits.count else { return }
        sharedVM.habits.remove(at: index)
    }

    func toggleSelection(at index: Int) {
        guard index >= 0 && index < sharedVM.habits.count else { return }
        sharedVM.habits[index].isSelected.toggle()
    }
}
