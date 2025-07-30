//
//  MyHabitModel.swift
//  Indayvidual
//
//  Created by 김도연 on 7/23/25.
//

import Foundation

struct MyHabitModel: Codable, Identifiable {
    var id = UUID()
    var title: String
    var colorName: String
    var checkedAt: String
    var isSelected: Bool

//    enum CodingKeys: String, CodingKey {
//        case id           = "habitId" 
//        case title         = "title"
//        case colorName    = "colorCode"
//        case checkedAt
//        case isSelected   = "checked"
//    }
}
