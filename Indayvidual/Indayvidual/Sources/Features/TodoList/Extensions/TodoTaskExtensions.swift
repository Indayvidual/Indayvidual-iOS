//
//  TodoTaskExtensions.swift
//  Indayvidual
//
//  Created by 김지민 on 7/30/25.
//

import Foundation
import SwiftUI

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
    func updateCategory(_ category: Category, newName: String, newColor: Color) {
        guard let index = categories.firstIndex(where: { $0.categoryId == category.categoryId }) else { return }
        categories[index] = Category(
            categoryId: category.categoryId,
            name: newName,
            color: newColor
        )
        // TODO: API
    }
    
    // 카테고리 삭제 + 삭제 할 카테고리에 있는 task들도 모두 삭제
    func deleteCategory(_ category: Category) {
        // 1. 카테고리 제거
        categories.removeAll { $0.categoryId == category.categoryId }
        // 2. 모든 날짜에서 해당 카테고리의 task 제거
        for key in tasks.keys {
            tasks[key]?.removeAll { $0.categoryId == category.categoryId }
        }
        // TODO: API
    }
}
