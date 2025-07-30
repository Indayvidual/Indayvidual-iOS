//
//  MyHabitModel.swift
//  Indayvidual
//
//  Created by 김도연 on 7/23/25.
//

import Foundation

struct MyHabitModel: Codable, Identifiable {
    var id = UUID()
    var habitId: Int?
    var title: String
    var colorName: String
    var checkedAt: String
    var isSelected: Bool
}

extension MyHabitModel {
    func toCreateDTO() -> CreateHabitRequestDTO {
        return CreateHabitRequestDTO(
            title: title,
            colorCode: colorName
        )
    }

    func toUpdateDTO() -> UpdateHabitRequestDTO {
        return UpdateHabitRequestDTO(
            title: title,
            colorCode: colorName
        )
    }
}
