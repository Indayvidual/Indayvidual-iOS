//
//  DateFormat.swift
//  Indayvidual
//
//  Created by 김도연 on 8/6/25.
//

import Foundation

extension Date {
    func toDisplayFormat() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter.string(from: self)
    }

    func toAPIDateFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
