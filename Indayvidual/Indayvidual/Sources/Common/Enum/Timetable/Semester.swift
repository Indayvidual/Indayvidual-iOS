//
//  Semester.swift
//  Indayvidual
//
//  Created by 장주리 on 8/13/25.
//

enum Semester: String, CaseIterable, Identifiable {
    case grade1Term1 = "1학년 1학기"
    case grade1Term2 = "1학년 2학기"
    case grade2Term1 = "2학년 1학기"
    case grade2Term2 = "2학년 2학기"
    case grade3Term1 = "3학년 1학기"
    case grade3Term2 = "3학년 2학기"
    case grade4Term1 = "4학년 1학기"
    case grade4Term2 = "4학년 2학기"
    
    var id: String { rawValue }
}
