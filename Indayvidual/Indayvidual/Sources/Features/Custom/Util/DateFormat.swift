//
//  DateFormat.swift
//  Indayvidual
//
//  Created by 김도연 on 8/6/25.
//

import Foundation

// MARK: - Date 포맷
extension Date {
    func toDisplayFormat() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter.string(from: self)
    }

    func toAPIDateFormat() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    func toYYMMDD() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyMMdd"
        return formatter.string(from: self)
    }
    
    func toHHmm() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}

// MARK: - String 포맷
extension String {
    private func parseAPIDate() -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        return formatter.date(from: self)
    }
    
    func asYYMMDD() -> String {
        guard let date = parseAPIDate() else { return "" }
        return date.toYYMMDD()
    }
    
    func asHHmm() -> String {
        guard let date = parseAPIDate() else { return "" }
        return date.toHHmm()
    }
}
