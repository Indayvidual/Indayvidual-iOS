//
//  TodoTaskExtensions.swift
//  Indayvidual
//
//  Created by 김지민 on 7/30/25.
//

import Foundation
import SwiftUI
import Moya

extension CheckListItem {
    func toTodoTask(categoryId: Int, date: String, order: Int) -> TodoTask {
        return TodoTask(
            taskId: nil,
            categoryId: categoryId,
            title: self.text,
            isCompleted: self.isChecked,
            order: order,
            date: date
        )
    }
}

extension TodoTask {
    func toCheckListItem() -> CheckListItem {
        return CheckListItem(text: self.title, isChecked: self.isCompleted)
    }
}

extension TodoViewModel {
    // 카테고리 이름, 색상 수정
    func updateCategory(_ category: Category, newName: String, newColor: Color, completion: ((Bool) -> Void)? = nil) {
        guard let categoryId = category.categoryId else {
            completion?(false)
            return
        }
        
        errorMessage = nil
        
        let colorHex = newColor.toHex()
        
        categoryProvider.request(TodoCategoryAPITarget.updateCategory(categoryId: categoryId, name: newName, color: colorHex)) { [weak self] result in
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
                            // 로컬 데이터 업데이트
                            if let index = self?.categories.firstIndex(where: { $0.categoryId == categoryId }) {
                                self?.categories[index] = Category(
                                    categoryId: apiResponse.data.categoryId,
                                    name: apiResponse.data.name,
                                    color: Color(hex: apiResponse.data.color) ?? newColor
                                )
                            }
                            print("🟢 카테고리 수정 성공: \(apiResponse.data)")
                            completion?(true)
                        } else {
                            self?.errorMessage = apiResponse.message
                            completion?(false)
                        }
                    } catch {
                        self?.errorMessage = "파싱 에러: \(error.localizedDescription)"
                        print("🔴 [DECODING ERROR] 카테고리 수정 응답 디코딩 실패: \(error)")
                        completion?(false)
                    }
                    
                case .failure(let error):
                    self?.errorMessage = "수정 실패: \(error.localizedDescription)"
                    print("🔴 [API ERROR] 카테고리 수정 실패: \(error)")
                    completion?(false)
                }
            }
        }
    }
    
    // 카테고리 삭제 + 삭제 할 카테고리에 있는 task들도 모두 삭제
    func deleteCategory(_ category: Category) {
        guard let categoryId = category.categoryId else { return }
        errorMessage = nil

        categoryProvider.request(TodoCategoryAPITarget.deleteCategory(categoryId: categoryId)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard 200...299 ~= response.statusCode else {
                        self?.errorMessage = "서버 에러: HTTP \(response.statusCode)"
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(APIResponse<EmptyResult>.self, from: response.data)
                        if apiResponse.isSuccess {
                            // 로컬에서 캐시된 데이터 제거
                            self?.categories.removeAll { $0.categoryId == categoryId }
                            // 카테고리에 속한 모든 task 제거
                            if let keys = self?.tasks.keys {
                                for key in keys {
                                    self?.tasks[key]?.removeAll { $0.categoryId == categoryId }
                                }
                            }
                            print("🟢 카테고리 삭제 성공")
                        } else {
                            self?.errorMessage = apiResponse.message
                        }
                    } catch {
                        self?.errorMessage = "파싱 에러: \(error.localizedDescription)"
                    }
                case .failure(let error):
                    self?.errorMessage = "삭제 실패: \(error.localizedDescription)"
                }
            }
        }
    }
}
