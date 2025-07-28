//
//  CustomCalendarResponseDto.swift
//  Indayvidual
//
//  Created by 장주리 on 7/28/25.
//

import Foundation

struct CustomCalendarResponseDto: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let data: [CustomCalendarDto]
}
