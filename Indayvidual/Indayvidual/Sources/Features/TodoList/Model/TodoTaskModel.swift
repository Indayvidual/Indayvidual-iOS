//
//  TodoTaskModel.swift
//  Indayvidual
//
//  Created by 김지민 on 7/30/25.
//

import Foundation

struct TodoTask: Identifiable, Hashable {
    let id = UUID()
    let taskId: Int?
    let categoryId: Int
    var title: String
    var isCompleted: Bool
    var order: Int
    let date: String // "yyyy-MM-dd"
    
    // 날짜 비교 목적
    var taskDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: date) ?? Date()
    }
}
