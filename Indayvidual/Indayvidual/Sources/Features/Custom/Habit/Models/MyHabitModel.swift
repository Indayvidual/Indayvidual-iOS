//
//  MyHabitModel.swift
//  Indayvidual
//
//  Created by 김도연 on 7/23/25.
//

import Foundation

struct MyHabitModel: Identifiable {
    let id: UUID
    var name: String
    var colorName: String
    var isSelected: Bool = false
}
