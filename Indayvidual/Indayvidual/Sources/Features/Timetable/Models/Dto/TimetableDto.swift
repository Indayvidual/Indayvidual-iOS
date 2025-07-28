//
//  TimetableDto.swift
//  Indayvidual
//
//  Created by 장주리 on 7/28/25.
//

import Foundation

struct TimetableDto: Codable {
    let timetableId: Int
    let schoolId: String
    let semester: String
    let imageUrl: String
}
