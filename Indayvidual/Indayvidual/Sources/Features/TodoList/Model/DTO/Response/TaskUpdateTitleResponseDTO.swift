//
//  TaskUpdateTitleResponseDTO.swift
//  Indayvidual
//
//  Created by 김지민 on 7/28/25.
//

import Foundation

struct TaskUpdateTitleResponseDTO : Decodable {
    let taskId : Int
    let title : String
    let isCompleted : Bool
}
