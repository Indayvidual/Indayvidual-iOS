//
//  TodoViewModel.swift
//  Indayvidual
//
//  Created by 김지민 on 7/30/25.
//

import Foundation
import SwiftUI
import Moya

@MainActor
class TodoViewModel: ObservableObject {
    let categoryProvider = MoyaProvider<TodoCategoryAPITarget>()

    @Published var tasks: [String: [TodoTask]] = [:] // 날짜별로 관리
    @Published var selectedDate: String = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }() // 현재 날짜로 초기화
    @Published var categories: [Category] = [] // 카테고리 배열 추가
    @Published var isLoading: Bool = false // 로딩 상태 추가
    @Published var errorMessage: String? = nil // 에러 메시지 추가
    
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
    
    // 카테고리 추가 - API 호출 포함
    func addCategory(name: String, color: Color, completion: ((Bool) -> Void)? = nil) {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        let colorHex = color.toHex()

        categoryProvider.request(TodoCategoryAPITarget.postCategories(name: name, color: colorHex)) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    guard 200...299 ~= response.statusCode else {
                        self?.errorMessage = "서버 에러: HTTP \(response.statusCode)"
                        completion?(false)
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(APIResponse<CategoryResponseDTO>.self, from: response.data)
                        if apiResponse.isSuccess {
                            print("🟢 [SUCCESS] 카테고리 추가 성공: \(name), 색상: \(colorHex)")
                            self?.fetchCategories()
                            completion?(true)
                        } else {
                            self?.errorMessage = apiResponse.message
                            completion?(false)
                        }
                    } catch {
                        self?.errorMessage = "디코딩 실패: \(error.localizedDescription)"
                        completion?(false)
                    }
                case .failure(let error):
                    self?.errorMessage = "등록 실패: \(error.localizedDescription)"
                    completion?(false)
                }
            }
        }
    }

    //카테고리 조회
    func fetchCategories() {
        isLoading = true
        errorMessage = nil
        
        categoryProvider.request(.getCategories) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    guard 200...299 ~= response.statusCode else {
                        self?.errorMessage = "서버 에러: HTTP \(response.statusCode)"
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(APIResponse<[CategoryResponseDTO]>.self, from: response.data)
                        if apiResponse.isSuccess {
                            self?.categories = apiResponse.data.map {
                                Category(
                                    categoryId: $0.categoryId,
                                    name: $0.name,
                                    color: Color(hex: $0.color) ?? .purple
                                )
                            }
                        } else {
                            self?.errorMessage = apiResponse.message
                        }
                    } catch {
                        self?.errorMessage = "파싱 에러: \(error.localizedDescription)"
                    }
                case .failure(let error):
                    self?.errorMessage = "조회 실패: \(error.localizedDescription)"
                }
            }
        }
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
        var updatedTask = tasks[task.date]![index]
        updatedTask.isCompleted.toggle()
        tasks[task.date]![index] = updatedTask  // 새로운 값으로 교체
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
