//
//  TaskUpdateOrderRequestDTO.swift
//  Indayvidual
//
//  Created by 김지민 on 7/28/25.
//

import Foundation

struct TaskUpdateOrderRequestDTO: Encodable {
    let tasks: [TaskOrderInfo]
}

struct TaskOrderInfo: Encodable {
    let taskId: Int
    let categoryId: Int
    let order: Int
}
