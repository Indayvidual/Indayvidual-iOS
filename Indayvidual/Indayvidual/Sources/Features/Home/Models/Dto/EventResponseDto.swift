//
//  EventResponseDto.swift
//  Indayvidual
//
//  Created by 장주리 on 7/28/25.
//

import Foundation

struct EventResponseDto: Codable{
    var eventId: Int
    var title: String
    var startTime: String?
    var endTime: String?
    var color: String
}
