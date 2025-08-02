//
//  TodoViewModel.swift
//  Indayvidual
//
//  Created by 김지민 on 7/30/25.
//

import Foundation
import SwiftUI

@MainActor
class TodoViewModel: ObservableObject {
    @Published var tasks: [String: [TodoTask]] = [:] // 날짜별로 관리
    @Published var selectedDate: String = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }() // 현재 날짜로 초기화
    @Published var categories: [Category] = [] // 카테고리 배열 추가
    
    private var nextCategoryId: Int = 1
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // 선택된 날짜의 투두 리스트
    var tasksForSelectedDate: [TodoTask] {
        tasks[selectedDate] ?? []
    }
    
    // 특정 날짜의 tasks 가져오기
    func tasks(for date: String) -> [TodoTask] {
        return tasks[date] ?? []
    }
    
    // 특정 날짜의 특정 카테고리 tasks
    func tasks(for date: String, categoryId: Int) -> [TodoTask] {
        return tasks(for: date).filter { $0.categoryId == categoryId }
    }
    
    // 카테고리 추가
    func addCategory(name: String, color: Color) {
        let newCategory = Category(
            categoryId: nextCategoryId,
            name: name,
            color: color
        )
        categories.append(newCategory)
        nextCategoryId += 1
        // TODO: API 호출
    }
    
    // Task 추가
    func addTask(title: String, categoryId: Int, date: String) {
        let newTask = TodoTask(
            taskId: nil,
            categoryId: categoryId,
            title: title,
            isCompleted: false,
            order: tasks[date]?.count ?? 0,
            date: date
        )
        if tasks[date] == nil {
            tasks[date] = []
        }
        tasks[date]?.append(newTask)
        // TODO: API 호출
    }
    
    // Task 체크 토글
    func toggleTask(_ task: TodoTask) {
        guard let index = tasks[task.date]?.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[task.date]?[index].isCompleted.toggle()
        // TODO: API 호출
    }
    
    // Task 제목 수정
    func updateTaskTitle(_ task: TodoTask, newTitle: String) {
        guard let index = tasks[task.date]?.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[task.date]?[index].title = newTitle
        // TODO: API 호출
    }
    
    // Task 날짜 이동 (이동: 기존 날짜에서 삭제, 새 날짜에 추가)
    func moveTask(_ task: TodoTask, to newDate: String) {
        guard let oldIndex = tasks[task.date]?.firstIndex(where: { $0.id == task.id }) else { return }
        let movedTask = TodoTask(
            taskId: task.taskId,
            categoryId: task.categoryId,
            title: task.title,
            isCompleted: task.isCompleted,
            order: tasks[newDate]?.count ?? 0,
            date: newDate
        )
        // 기존 날짜에서 삭제
        tasks[task.date]?.remove(at: oldIndex)
        // 새 날짜에 추가
        if tasks[newDate] == nil {
            tasks[newDate] = []
        }
        tasks[newDate]?.append(movedTask)
        // TODO: API 호출
    }
    
    // Task 복사 (복사: 기존 날짜는 그대로 두고, 새 날짜에 추가)
    func duplicateTask(_ task: TodoTask, to newDate: String) {
        let newTask = TodoTask(
            taskId: nil,
            categoryId: task.categoryId,
            title: task.title,
            isCompleted: false,
            order: tasks[newDate]?.count ?? 0,
            date: newDate
        )
        if tasks[newDate] == nil {
            tasks[newDate] = []
        }
        tasks[newDate]?.append(newTask)
        // TODO: API 호출
    }
    
    // Task 삭제
    func deleteTask(_ task: TodoTask) {
        guard let index = tasks[task.date]?.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[task.date]?.remove(at: index)
        // TODO: API 호출
    }
    
    private func findTaskIndex(_ task: TodoTask) -> Int? {
        return tasks[task.date]?.firstIndex { $0.id == task.id }
    }
    
    func moveTask(from source: IndexSet, to destination: Int, date: String) {
        guard var taskList = tasks[date] else { return }
        taskList.move(fromOffsets: source, toOffset: destination)
        
        // 변경된 순서대로 order (0부터 부여)
        for (index, var task) in taskList.enumerated() {
            if task.order != index {
                task.order = index
                taskList[index] = task
            }
        }
        tasks[date] = taskList
        
        // TODO: API 호출
    }
}
