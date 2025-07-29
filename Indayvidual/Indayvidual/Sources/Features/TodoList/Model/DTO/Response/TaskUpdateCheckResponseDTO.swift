//
//  TaskUpdateCheckResponseDTO.swift
//  Indayvidual
//
//  Created by 김지민 on 7/28/25.
//

import Foundation

struct TaskUpdateCheckResponseDTO : Encodable {
    let taskId : Int
    let isCompleted : Bool
}
