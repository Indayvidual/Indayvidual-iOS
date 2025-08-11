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
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    func toYYMMDD() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMdd"
        return formatter.string(from: self)
    }
    
    func toHHmm() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}

// MARK: - String 포맷
extension String {
    func asYYMMDD() -> String {
        let inF = DateFormatter()
        inF.locale = Locale(identifier: "ko_KR")
        inF.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        guard let date = inF.date(from: self) else { return "" }

        let outF = DateFormatter()
        outF.locale = Locale(identifier: "ko_KR")
        outF.dateFormat = "yyMMdd"
        return outF.string(from: date)
    }

    func asHHmm() -> String {
        let inF = DateFormatter()
        inF.locale = Locale(identifier: "ko_KR")
        inF.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        guard let date = inF.date(from: self) else { return "" }

        let outF = DateFormatter()
        outF.locale = Locale(identifier: "ko_KR")
        outF.dateFormat = "HH:mm"
        return outF.string(from: date)
    }
}
