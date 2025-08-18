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
    
    var alertService: AlertService
    init(alertService: AlertService) {
        self.alertService = alertService
    }
    
    @Published var selectedDate: String = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }() // 현재 날짜로 초기화
    @Published var categories: [Category] = [] // 카테고리 배열 추가
    @Published var errorMessage: String? = nil // 에러 메시지 추가
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    @Published var tasks: [String: [TodoTask]] = [:] // 날짜별로 관리

    // MARK: - handleError 함수
    private func handleError(_ message: String, retry: (() -> Void)? = nil) {
        print("🔴 [ERROR] \(message)")
        DispatchQueue.main.async {
            self.errorMessage = message
            
            if let retryAction = retry {
                self.alertService.showAlert(
                    title: "오류 발생",
                    message: message,
                    primaryButton: .primary(title: "재시도", action: retryAction),
                    secondaryButton: .secondary(title: "확인", action: { }),
                )
            } else {
                self.alertService.showAlert(
                    title: "오류 발생",
                    message: message,
                    primaryButton: .primary(title: "확인", action: { })
                )
            }
        }
    }
    
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
        var tempTasksForDate: [TodoTask] = []
        let lock = NSLock()

        for category in categories {
            guard let categoryId = category.categoryId else { continue }
            group.enter()
            fetchTasks(for: categoryId, date: date) { fetchedTasks, success in
                lock.lock()
                defer { lock.unlock() }

                if !success {
                    hasError = true
                } else {
                    tempTasksForDate.append(contentsOf: fetchedTasks)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if !hasError {
                self.tasks[date] = tempTasksForDate.sorted { $0.order < $1.order }
            }
            completion?(!hasError)
        }
    }

    func loadTasks(for date: String, categoryId: Int, completion: ((Bool) -> Void)? = nil) {
        fetchTasks(for: categoryId, date: date) { fetchedTasks, success in
            if success {
                DispatchQueue.main.async {
                    if self.tasks[date] == nil {
                        self.tasks[date] = []
                    }
                    self.tasks[date]?.removeAll { $0.categoryId == categoryId }
                    self.tasks[date]?.append(contentsOf: fetchedTasks)
                    self.tasks[date]?.sort { $0.order < $1.order }
                    completion?(true)
                }
            } else {
                completion?(false)
            }
        }
    }
    
    // 단일 카테고리 할 일 - 서버에서 데이터 로드
    func fetchTasks(for categoryId: Int, date: String, completion: @escaping ([TodoTask], Bool) -> Void) {
        taskProvider.request(.getTasks(categoryId: categoryId, date: date)) { result in
            switch result {
            case .success(let response):
                guard 200...299 ~= response.statusCode else {
                    self.handleError("서버 에러: HTTP \(response.statusCode)", retry: {
                        self.fetchTasks(for: categoryId, date: date, completion: completion)
                    })
                    completion([], false)
                    return
                }
                do {
                    let apiResponse = try JSONDecoder().decode(APIResponse<[TaskSpecificCategoryResponseDTO]>.self, from: response.data)
                    if apiResponse.isSuccess {
                        print("📥 [FETCH DEBUG] \(date) / 카테고리 \(categoryId) 서버 응답 순서:")
                        for dto in apiResponse.data {
                            print("    taskId:\(dto.taskId) order:\(dto.order) title:\(dto.title)")
                        }
                        
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
                        
                        completion(fetchedTasks, true)
                    } else {
                        self.handleError(apiResponse.message )
                        completion([], false)
                    }
                } catch {
                    self.handleError("파싱 에러: \(error.localizedDescription)")
                    completion([], false)
                }
            case .failure(let error):
                self.handleError("네트워크 오류: \(error.localizedDescription)", retry: {
                    self.fetchTasks(for: categoryId, date: date, completion: completion)
                })
                completion([], false)
            }
        }
    }
    
    // 모든 카테고리 단일 fetch
    func fetchAllTasks(for date: String) {
        for category in categories {
            guard let categoryId = category.categoryId else { continue }
            loadTasks(for: date, categoryId: categoryId)
        }
    }

    // MARK: - 카테고리 추가/조회
    func addCategory(name: String, color: Color, completion: ((Bool) -> Void)? = nil) {
        let colorHex = color.toHex()
        
        categoryProvider.request(TodoCategoryAPITarget.postCategories(name: name, color: colorHex)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard 200...299 ~= response.statusCode else {
                        self?.handleError("서버 에러: HTTP \(response.statusCode)")
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
                            self?.handleError(apiResponse.message)
                            completion?(false)
                        }
                    } catch {
                        self?.handleError("디코딩 실패: \(error.localizedDescription)")
                        completion?(false)
                    }
                case .failure(let error):
                    self?.handleError("등록 실패: \(error.localizedDescription)")
                    completion?(false)
                }
            }
        }
    }

    func fetchCategories() {
        categoryProvider.request(.getCategories) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard 200...299 ~= response.statusCode else {
                        self?.handleError("서버 에러: HTTP \(response.statusCode)")
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
                            self?.handleError(apiResponse.message )
                        }
                    } catch {
                        self?.handleError("파싱 에러: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    self?.handleError("조회 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Task 추가/변경/삭제/이동
    func addTask(title: String, categoryId: Int, date: String) {
        taskProvider.request(.postTasks(categoryId: categoryId, title: title, date: date)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard 200...299 ~= response.statusCode else {
                        self?.handleError("서버 에러: HTTP \(response.statusCode)")
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(APIResponse<TaskResponseDTO>.self, from: response.data)
                        if apiResponse.isSuccess {
                            self?.loadTasks(for: date)
                        } else {
                            self?.handleError(apiResponse.message)
                        }
                    } catch {
                        self?.handleError("파싱 에러: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    self?.handleError("추가 실패: \(error.localizedDescription)")
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

        taskProvider.request(.patchCheck(taskId: taskId, isCompleted: updatedTask.isCompleted)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard 200...299 ~= response.statusCode else {
                        if let index = self?.tasks[task.date]?.firstIndex(where: { $0.id == task.id }) {
                            self?.tasks[task.date]![index].isCompleted.toggle()
                        }
                        self?.handleError("서버 에러: HTTP \(response.statusCode)")
                        return
                    }
                case .failure(let error):
                    if let index = self?.tasks[task.date]?.firstIndex(where: { $0.id == task.id }) {
                        self?.tasks[task.date]![index].isCompleted.toggle()
                    }
                    self?.handleError("체크 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    func updateTaskTitle(_ task: TodoTask, newTitle: String) {
        guard let taskId = task.taskId else { return }
        guard let index = tasks[task.date]?.firstIndex(where: { $0.id == task.id }) else { return }
        let oldTitle = tasks[task.date]![index].title
        tasks[task.date]![index].title = newTitle

        taskProvider.request(.patchTitle(taskId: taskId, title: newTitle)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard 200...299 ~= response.statusCode else {
                        if let index = self?.tasks[task.date]?.firstIndex(where: { $0.id == task.id }) {
                            self?.tasks[task.date]![index].title = oldTitle
                        }
                        self?.handleError("서버 에러: HTTP \(response.statusCode)")
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
                            self?.handleError(apiResponse.message)
                        }
                    } catch {
                        if let index = self?.tasks[task.date]?.firstIndex(where: { $0.id == task.id }) {
                            self?.tasks[task.date]![index].title = oldTitle
                        }
                        self?.handleError("파싱 에러: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    if let index = self?.tasks[task.date]?.firstIndex(where: { $0.id == task.id }) {
                        self?.tasks[task.date]![index].title = oldTitle
                    }
                    self?.handleError("제목 수정 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    func moveTask(_ task: TodoTask, to newDate: String) {
        guard let taskId = task.taskId else { return }

        taskProvider.request(.patchDueDate(taskId: taskId, date: newDate)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard 200...299 ~= response.statusCode else {
                        self?.handleError("서버 에러: HTTP \(response.statusCode)")
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
                            self?.handleError(apiResponse.message)
                        }
                    } catch {
                        self?.handleError("파싱 에러: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    self?.handleError("날짜 이동 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    func duplicateTask(_ task: TodoTask, to newDate: String) {
        addTask(title: task.title, categoryId: task.categoryId, date: newDate)
    }
    
    func deleteTask(_ task: TodoTask) {
        guard let taskId = task.taskId else { return }

        taskProvider.request(.deleteTasks(taskId: taskId)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard 200...299 ~= response.statusCode else {
                        self?.handleError("서버 에러: HTTP \(response.statusCode)")
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
                            self?.handleError(apiResponse.message)
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
                    self?.handleError("삭제 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - 카테고리별 순서 변경
    func updateTaskOrderForCategory(date: String, taskOrderInfos: [TaskOrderInfo]) {
        guard !taskOrderInfos.isEmpty,
              let categoryId = taskOrderInfos.first?.categoryId else { return }

        // 로컬 상태를 먼저 업데이트
        var allTasksForDate = tasks[date] ?? []
        allTasksForDate.removeAll { $0.categoryId == categoryId }
        
        let newCategoryTasks = taskOrderInfos.map { info in
            // 기존 task 객체에 새로운 order 값만 반영
            var task = self.tasks(for: date, categoryId: categoryId).first { $0.taskId == info.taskId } ??
                        // 기존 task를 찾지 못할 경우를 대비하여 더미 생성
                        TodoTask(taskId: info.taskId, categoryId: info.categoryId, title: "", isCompleted: false, order: info.order, date: date)
            task.order = info.order
            return task
        }
        allTasksForDate.append(contentsOf: newCategoryTasks)
        tasks[date] = allTasksForDate.sorted { $0.categoryId < $1.categoryId || ($0.categoryId == $1.categoryId && $0.order < $1.order) }
        
        print("🚀 [DEBUG] 서버로 전송되는 JSON 페이로드:")
        let payload = ["tasks": taskOrderInfos]
        do {
            let jsonData = try JSONEncoder().encode(payload)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "Invalid JSON"
            print(jsonString)
        } catch {
            print("🔴 [DEBUG] JSON 인코딩 실패: \(error)")
        }

        // 서버에 순서 변경 요청
        taskProvider.request(.patchOrder(tasks: taskOrderInfos)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if 200...299 ~= response.statusCode {
                        print("🟢 \(date) 카테고리 \(categoryId) 순서 변경 성공")
                        self?.loadTasks(for: date, categoryId: categoryId)
                    } else {
                        print("🔴 \(date) 카테고리 \(categoryId) 순서 변경 실패: HTTP \(response.statusCode)")
                        self?.handleError("순서 변경 실패: HTTP \(response.statusCode)", retry: {
                            self?.updateTaskOrderForCategory(date: date, taskOrderInfos: taskOrderInfos)
                        })
                        self?.loadTasks(for: date, categoryId: categoryId)
                    }
                case .failure(let error):
                    print("🔴 \(date) 카테고리 \(categoryId) 순서 변경 실패: \(error)")
                    self?.handleError("순서 변경 실패: \(error.localizedDescription)", retry: {
                        self?.updateTaskOrderForCategory(date: date, taskOrderInfos: taskOrderInfos)
                    })
                    self?.loadTasks(for: date, categoryId: categoryId)
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
}
