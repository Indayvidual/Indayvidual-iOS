//
//  ScheduleItem.swift
//  Indayvidual
//
//  Created by 장주리 on 7/30/25.
//

import SwiftUI

struct ScheduleItem: Identifiable, Comparable {
    let id = UUID()
    let startTime: Date
    let endTime: Date?
    let title: String
    let color: Color

    static func < (lhs: ScheduleItem, rhs: ScheduleItem) -> Bool {
        return lhs.startTime < rhs.startTime
    }
}

extension Date {
    func toTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}
