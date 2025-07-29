//
//  TaskSpecificCategoryResponse.swift
//  Indayvidual
//
//  Created by 김지민 on 7/29/25.
//

import Foundation
struct TaskSpecificCategoryResponseDTO : Decodable {
    let taskId : Int
    let title : String
    let isCompleted : Bool
    let order : Int
    let date : String
}
