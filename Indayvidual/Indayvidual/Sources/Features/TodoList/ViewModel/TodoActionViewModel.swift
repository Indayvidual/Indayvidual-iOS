//
//  TodoActoinViewModel.swift
//  Indayvidual
//
//  Created by 김지민 on 7/30/25.
//

import Foundation

@MainActor
class TodoActionViewModel: ObservableObject {
    @Published var showDatePicker = false
    @Published var selectedActionDate = Date()
    
    let todoManager: TodoViewModel
    
    init(todoManager: TodoViewModel) {
        self.todoManager = todoManager
    }
    
    func handleAction(_ option: TodoActionOption, for task: TodoTask) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        switch option {
        case .changeDate:
            selectedActionDate = task.taskDate
            showDatePicker = true
            
        case .doToday:
            let today = dateFormatter.string(from: Date())
            if task.isCompleted {
                todoManager.duplicateTask(task, to: today)
            } else {
                todoManager.moveTask(task, to: today)
            }
            
        case .doTomorrow:
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            let tomorrowString = dateFormatter.string(from: tomorrow)
            if task.isCompleted {
                todoManager.duplicateTask(task, to: tomorrowString) // 완료된 task는 복사
            } else {
                todoManager.moveTask(task, to: tomorrowString) // 미완료된 task는 이동
            }
            
        case .doAnotherDay:
            selectedActionDate = Date()
            showDatePicker = true
            
        case .doTodoayAgain:
            let today = dateFormatter.string(from: Date())
            todoManager.duplicateTask(task, to: today)

        case .delete:
            todoManager.deleteTask(task)
        }
    }
    
    func handleDateSelection(for task: TodoTask, option: TodoActionOption) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDateString = dateFormatter.string(from: selectedActionDate)
        
        switch option {
        case .changeDate:
            todoManager.moveTask(task, to: selectedDateString)
        case .doAnotherDay:
            todoManager.duplicateTask(task, to: selectedDateString)
        default:
            break
        }
        
        showDatePicker = false
    }
}
