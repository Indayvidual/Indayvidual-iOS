//
//  MyHabitViewModel.swift
//  Indayvidual
//
//  Created by 김도연 on 7/23/25.
//

import Foundation
import SwiftUI

class HabitViewModel: ObservableObject {
    @Published var habits: [MyHabitModel] = []
    
    func addHabit(name: String, colorName: String) {
        let newHabit = MyHabitModel(id: UUID(), name: name, colorName: colorName)
        habits.append(newHabit)
    }

    func deleteHabit(_ habit: MyHabitModel) {
        habits.removeAll { $0.id == habit.id }
    }

    func updateHabit(_ habit: MyHabitModel, name: String, colorName: String) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].name = name
            habits[index].colorName = colorName
        }
    }

    func toggleCompletion(for habit: MyHabitModel) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].isSelected.toggle()
        }
    }
}
