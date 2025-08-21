//
//  TaskResponseDTO.swift
//  Indayvidual
//
//  Created by 김지민 on 7/28/25.
//

import Foundation

struct TaskResponseDTO : Decodable {
    let taskId : Int
    let categoryId : Int
    let title : String
    let isCompleted : Bool
    let order : Int
    let date : String
}
