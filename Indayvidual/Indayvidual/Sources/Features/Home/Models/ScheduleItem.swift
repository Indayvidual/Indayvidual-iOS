//
//  ScheduleItem.swift
//  Indayvidual
//
//  Created by 장주리 on 7/30/25.
//

import SwiftUI

struct ScheduleItem: Identifiable, Comparable {
    let id: Int
    let startTime: Date?
    let endTime: Date?
    let title: String
    let color: Color
    let isAllDay: Bool
    
    init(
        id: Int,
        startTime: Date?,
        endTime: Date? = nil,
        title: String,
        color: Color,
        isAllDay: Bool = false
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.title = title
        self.color = color
        self.isAllDay = isAllDay
    }
    
    static func < (lhs: ScheduleItem, rhs: ScheduleItem) -> Bool {
        switch (lhs.startTime, rhs.startTime) {
        case let (l?, r?):
            return l < r
        case (nil, _?):
            return true        // nil은 항상 더 이전으로 간주
        case (_?, nil):
            return false
        case (nil, nil):
            return false       // 둘 다 nil이면 동등 처리
        }
    }
}

extension ScheduleItem {
    var timeText: String {
        guard let start = startTime else { return "" }
        
        if let end = endTime {
            return "\(start.toTimeString()) - \(end.toTimeString())"
        } else {
            return start.toTimeString()
        }
    }
}
