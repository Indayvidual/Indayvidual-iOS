//
//  TaskOrderUpdateResponseDTO.swift
//  Indayvidual
//
//  Created by 김지민 on 8/11/25.
//

import Foundation

struct TaskOrderUpdateResponseDTO: Codable {
    let updatedCount: Int
    let affectedCategories: [Int]
}
