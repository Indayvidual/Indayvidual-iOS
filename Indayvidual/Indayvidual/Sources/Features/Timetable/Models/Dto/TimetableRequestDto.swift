//
//  TimetableRequestDto.swift
//  Indayvidual
//
//  Created by 장주리 on 7/28/25.
//

import Foundation

struct TimetableRequestDto: Codable {
    let schoolId: Int
    let semester: String
    let imageUrl: String
}
