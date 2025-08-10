//
//  String.swift
//  Indayvidual
//
//  Created by 장주리 on 8/6/25.
//

import Foundation

extension String {
    func toDate(format: String = "yyyy-MM-dd") -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = .current
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
    
    func toFullDate(on baseDate: Date) -> Date? {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "HH:mm"
            
            guard let time = formatter.date(from: self) else {
                return nil
            }

            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: baseDate)
            let hour = calendar.component(.hour, from: time)
            let minute = calendar.component(.minute, from: time)
            
            return calendar.date(from: DateComponents(
                year: dateComponents.year,
                month: dateComponents.month,
                day: dateComponents.day,
                hour: hour,
                minute: minute
            ))
        }
}


