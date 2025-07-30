//
//  CustomViewModel.swift
//  Indayvidual
//
//  Created by 김도연 on 7/6/25.
//

import Foundation
import SwiftUI
import Observation

@Observable
class CustomViewModel {
    var name: String = "인데비"
    
    //MARK: - 메모
    var memos: [MemoModel] = [
        MemoModel(title: "메모1", content: "긴 내용1\n내용1내용1내용1내용1내용1내용1내용1내용1내용1", date: "250718", time: "12:00"),
        MemoModel(title: "메모2", content: "내용2\n내용2", date: "250717", time: "13:00"),
        MemoModel(title: "메모3", content: "내용3", date: "250717", time: "13:00"),
    ]
    var memosCount: Int {
        memos.count
    }
    func deleteMemo(at index: Int) {
        memos.remove(at: index)
    }
    
    //MARK: - 습관
    var habits: [MyHabitModel] = [
        MyHabitModel(title: "Habit1", colorName: "peach-03", checkedAt: "", isSelected: true),
        MyHabitModel(title: "Habit2", colorName: "teal-03", checkedAt: "", isSelected: false)
    ]
    var habitsSelectedCount: Int {
        habits.filter { $0.isSelected }.count
    }
}
