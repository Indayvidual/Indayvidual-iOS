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
    let taskProvider = MoyaProvider<TodoChecklistAPITarget>()

    @Published var tasks: [String: [TodoTask]] = [:] // 날짜별로 관리
    @Published var selectedDate: String = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }() // 현재 날짜로 초기화
    @Published var categories: [Category] = [] // 카테고리 배열 추가
    @Published var errorMessage: String? = nil // 에러 메시지 추가
    
    private var nextCategoryId: Int = 1
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    // MARK: - Task 조회
    func tasks(for date: String) -> [TodoTask] {
        return tasks[date] ?? []
    }

    func tasks(for date: String, categoryId: Int) -> [TodoTask] {
        return tasks(for: date).filter { $0.categoryId == categoryId }
    }

    // MARK: - 전체/카테고리별 로딩
    func loadTasksForSelectedDate(completion: ((Bool) -> Void)? = nil) {
        loadTasks(for: selectedDate, completion: completion)
    }

    func loadTasks(for date: String, completion: ((Bool) -> Void)? = nil) {
        guard !categories.isEmpty else {
            fetchCategories()
            return
        }
        let group = DispatchGroup()
        var hasError = false

        for category in categories {
            guard let categoryId = category.categoryId else { continue }
            group.enter()
            fetchTasks(for: categoryId, date: date) { success in
                if !success { hasError = true }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion?(!hasError)
        }
    }

    func loadTasks(for date: String, categoryId: Int, completion: ((Bool) -> Void)? = nil) {
        fetchTasks(for: categoryId, date: date, completion: completion)
    }

    // MARK: - 단일 카테고리 할 일
    func fetchTasks(for categoryId: Int, date: String, completion: ((Bool) -> Void)? = nil) {
        errorMessage = nil
        taskProvider.request(.getTasks(categoryId: categoryId, date: date)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard 200...299 ~= response.statusCode else {
                        self?.errorMessage = "서버 에러: HTTP \(response.statusCode)"
                        completion?(false)
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(APIResponse<[TaskSpecificCategoryResponseDTO]>.self, from: response.data)
                        if apiResponse.isSuccess {
                            let fetchedTasks = apiResponse.data.map { dto in
                                TodoTask(
                                    taskId: dto.taskId,
                                    categoryId: categoryId,
                                    title: dto.title,
                                    isCompleted: dto.isCompleted,
                                    order: dto.order,
                                    date: dto.date
                                )
                            }.sorted { $0.order < $1.order }
                            if self?.tasks[date] == nil {
                                self?.tasks[date] = []
                            }
                            self?.tasks[date]?.removeAll { $0.categoryId == categoryId }
                            self?.tasks[date]?.append(contentsOf: fetchedTasks)
                            self?.tasks[date]?.sort { $0.order < $1.order }
                            completion?(true)
                        } else {
                            self?.errorMessage = apiResponse.message
                            completion?(false)
                        }
                    } catch {
                        self?.errorMessage = "파싱 에러: \(error.localizedDescription)"
                        completion?(false)
                    }
                case .failure(let error):
                    self?.errorMessage = "조회 실패: \(error.localizedDescription)"
                    completion?(false)
                }
            }
        }
    }

    // 모든 카테고리 단일 fetch 
    func fetchAllTasks(for date: String) {
        for category in categories {
            guard let categoryId = category.categoryId else { continue }
            fetchTasks(for: categoryId, date: date)
        }
    }

    // MARK: - 카테고리 추가/조회
    func addCategory(name: String, color: Color, completion: ((Bool) -> Void)? = nil) {
        errorMessage = nil

        let colorHex = color.toHex()

        categoryProvider.request(TodoCategoryAPITarget.postCategories(name: name, color: colorHex)) { [weak self] result in
            DispatchQueue.main.async {
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

    func fetchCategories() {
        errorMessage = nil
        categoryProvider.request(.getCategories) { [weak self] result in
            DispatchQueue.main.async {
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
                            if let selectedDate = self?.selectedDate {
                                self?.fetchAllTasks(for: selectedDate)
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

    // MARK: - Task 추가/변경/삭제/이동
    func addTask(title: String, categoryId: Int, date: String) {
        errorMessage = nil
        taskProvider.request(.postTasks(categoryId: categoryId, title: title, date: date)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard 200...299 ~= response.statusCode else {
                        self?.errorMessage = "서버 에러: HTTP \(response.statusCode)"
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(APIResponse<TaskResponseDTO>.self, from: response.data)
                        if apiResponse.isSuccess {
                            self?.loadTasks(for: date)
                        } else {
                            self?.errorMessage = apiResponse.message
                        }
                    } catch {
                        self?.errorMessage = "파싱 에러: \(error.localizedDescription)"
                    }
                case .failure(let error):
                    self?.errorMessage = "추가 실패: \(error.localizedDescription)"
                }
            }
        }
    }

    func toggleTask(_ task: TodoTask) {
        guard let taskId = task.taskId else { return }
        guard let index = tasks[task.date]?.firstIndex(where: { $0.id == task.id }) else { return }
        var updatedTask = tasks[task.date]![index]
        updatedTask.isCompleted.toggle()
        tasks[task.date]![index] = updatedTask
        errorMessage = nil

        taskProvider.request(.patchCheck(taskId: taskId, isCompleted: updatedTask.isCompleted)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard 200...299 ~= response.statusCode else {
                        if let index = self?.tasks[task.date]?.firstIndex(where: { $0.id == task.id }) {
                            self?.tasks[task.date]![index].isCompleted.toggle()
                        }
                        self?.errorMessage = "서버 에러: HTTP \(response.statusCode)"
                        return
                    }
                case .failure(let error):
                    if let index = self?.tasks[task.date]?.firstIndex(where: { $0.id == task.id }) {
                        self?.tasks[task.date]![index].isCompleted.toggle()
                    }
                    self?.errorMessage = "체크 실패: \(error.localizedDescription)"
                }
            }
        }
    }

    func updateTaskTitle(_ task: TodoTask, newTitle: String) {
        guard let taskId = task.taskId else { return }
        guard let index = tasks[task.date]?.firstIndex(where: { $0.id == task.id }) else { return }
        let oldTitle = tasks[task.date]![index].title
        tasks[task.date]![index].title = newTitle
        errorMessage = nil

        taskProvider.request(.patchTitle(taskId: taskId, title: newTitle)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard 200...299 ~= response.statusCode else {
                        if let index = self?.tasks[task.date]?.firstIndex(where: { $0.id == task.id }) {
                            self?.tasks[task.date]![index].title = oldTitle
                        }
                        self?.errorMessage = "서버 에러: HTTP \(response.statusCode)"
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(APIResponse<TaskUpdateTitleResponseDTO>.self, from: response.data)
                        if apiResponse.isSuccess {
                            if let index = self?.tasks[task.date]?.firstIndex(where: { $0.id == task.id }) {
                                self?.tasks[task.date]![index].title = apiResponse.data.title
                                self?.tasks[task.date]![index].isCompleted = apiResponse.data.isCompleted
                            }
                        } else {
                            if let index = self?.tasks[task.date]?.firstIndex(where: { $0.id == task.id }) {
                                self?.tasks[task.date]![index].title = oldTitle
                            }
                            self?.errorMessage = apiResponse.message
                        }
                    } catch {
                        if let index = self?.tasks[task.date]?.firstIndex(where: { $0.id == task.id }) {
                            self?.tasks[task.date]![index].title = oldTitle
                        }
                        self?.errorMessage = "파싱 에러: \(error.localizedDescription)"
                    }
                case .failure(let error):
                    if let index = self?.tasks[task.date]?.firstIndex(where: { $0.id == task.id }) {
                        self?.tasks[task.date]![index].title = oldTitle
                    }
                    self?.errorMessage = "제목 수정 실패: \(error.localizedDescription)"
                }
            }
        }
    }

    func moveTask(_ task: TodoTask, to newDate: String) {
        guard let taskId = task.taskId else { return }
        errorMessage = nil
        taskProvider.request(.patchDueDate(taskId: taskId, date: newDate)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard 200...299 ~= response.statusCode else {
                        self?.errorMessage = "서버 에러: HTTP \(response.statusCode)"
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(APIResponse<TaskResponseDTO>.self, from: response.data)
                        if apiResponse.isSuccess {
                            if let oldIndex = self?.tasks[task.date]?.firstIndex(where: { $0.id == task.id }) {
                                let updatedTask = TodoTask(
                                    taskId: apiResponse.data.taskId,
                                    categoryId: apiResponse.data.categoryId,
                                    title: apiResponse.data.title,
                                    isCompleted: apiResponse.data.isCompleted,
                                    order: apiResponse.data.order,
                                    date: apiResponse.data.date
                                )
                                self?.tasks[task.date]?.remove(at: oldIndex)
                                if self?.tasks[newDate] == nil {
                                    self?.tasks[newDate] = []
                                }
                                self?.tasks[newDate]?.append(updatedTask)
                            }
                        } else {
                            self?.errorMessage = apiResponse.message
                        }
                    } catch {
                        self?.errorMessage = "파싱 에러: \(error.localizedDescription)"
                    }
                case .failure(let error):
                    self?.errorMessage = "날짜 이동 실패: \(error.localizedDescription)"
                }
            }
        }
    }

    func duplicateTask(_ task: TodoTask, to newDate: String) {
        addTask(title: task.title, categoryId: task.categoryId, date: newDate)
    }
    
    func deleteTask(_ task: TodoTask) {
        guard let taskId = task.taskId else { return }
        errorMessage = nil

        taskProvider.request(.deleteTasks(taskId: taskId)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard 200...299 ~= response.statusCode else {
                        self?.errorMessage = "서버 에러: HTTP \(response.statusCode)"
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(APIResponse<EmptyResult?>.self, from: response.data)
                        if apiResponse.isSuccess {
                            // 1) 로컬 캐시에서 삭제
                            if var currentTasks = self?.tasks[task.date] {
                                currentTasks.removeAll { $0.id == task.id }
                                var updatedDict = self?.tasks ?? [:]
                                updatedDict[task.date] = currentTasks
                                self?.tasks = updatedDict
                            }
                            // 2) 서버 최신 데이터로 다시 동기화
                            self?.loadTasks(for: task.date)
                        } else {
                            self?.errorMessage = apiResponse.message
                        }
                    } catch {
                        // 응답/파싱 오류 시에도 즉시 로컬 삭제 시도, 이후 서버 fetch로 보정
                        if var currentTasks = self?.tasks[task.date] {
                            currentTasks.removeAll { $0.id == task.id }
                            var updatedDict = self?.tasks ?? [:]
                            updatedDict[task.date] = currentTasks
                            self?.tasks = updatedDict
                        }
                        self?.loadTasks(for: task.date)
                    }

                case .failure(let error):
                    self?.errorMessage = "삭제 실패: \(error.localizedDescription)"
                }
            }
        }
    }

    // 순서 변경
    func moveTask(from source: IndexSet, to destination: Int, date: String) {
        guard var taskList = tasks[date] else { return }
        taskList.move(fromOffsets: source, toOffset: destination)

        var updatedTasks: [TodoTask] = []
        for (index, var task) in taskList.enumerated() {
            if task.order != index {
                task.order = index
                taskList[index] = task
            }
            updatedTasks.append(task)
        }
        tasks[date] = taskList

        let categoryGroups = Dictionary(grouping: updatedTasks) { $0.categoryId }
        for (categoryId, categoryTasks) in categoryGroups {
            let taskIds = categoryTasks.compactMap { $0.taskId }
            updateTaskOrder(categoryId: categoryId, taskOrder: taskIds)
        }
    }

    private func updateTaskOrder(categoryId: Int, taskOrder: [Int]) {
        taskProvider.request(.patchOrder(categoryId: categoryId, taskOrder: taskOrder)) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if 200...299 ~= response.statusCode {
                        print("🟢 [SUCCESS] 할 일 순서 변경 성공: 카테고리 \(categoryId)")
                    } else {
                        print("🔴 [ERROR] 할 일 순서 변경 실패: HTTP \(response.statusCode)")
                    }
                case .failure(let error):
                    print("🔴 [API ERROR] 할 일 순서 변경 실패: \(error)")
                }
            }
        }
    }
    
    @MainActor
    func loadTasksAsync(for date: String, categoryId: Int) async {
        await withCheckedContinuation { continuation in
            loadTasks(for: date, categoryId: categoryId) { _ in
                continuation.resume()
            }
        }
    }

    func addTempTask(for date: String, categoryId: Int) {
        let tasksForCategory = tasks(for: date, categoryId: categoryId)
        guard !(tasksForCategory.last?.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? false) else {
            return
        }
        let tempTask = TodoTask(
            taskId: nil,
            categoryId: categoryId,
            title: "",
            isCompleted: false,
            order: tasksForCategory.count,
            date: date
        )
        tasks[date, default: []].append(tempTask)
    }

    private func findTaskIndex(_ task: TodoTask) -> Int? {
        return tasks[task.date]?.firstIndex { $0.id == task.id }
    }
}
