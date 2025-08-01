//
//  TodoTaskExtensions.swift
//  Indayvidual
//
//  Created by 김지민 on 7/30/25.
//

import Foundation

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
