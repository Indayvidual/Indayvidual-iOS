//
//  EventCreateRequestDto.swift
//  Indayvidual
//
//  Created by 장주리 on 7/28/25.
//

import Foundation

struct EventCreateRequestDto: Codable{
    let date: String
    let title: String
    let startTime: String?
    let endTime: String?
    let color: String
    let isAllDay: Bool
}
