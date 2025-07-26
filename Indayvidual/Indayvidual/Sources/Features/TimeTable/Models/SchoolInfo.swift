//
//  SchoolInfo.swift
//  Indayvidual
//
//  Created by 장주리 on 7/23/25.
//

import Foundation

struct SchoolInfo: Codable, Identifiable {
    let id = UUID()
    let name: String

    enum CodingKeys: String, CodingKey {
        case name = "schoolName"
    }
}

// MARK: - API 응답 파싱용 구조체
struct SchoolData: Codable {
    let dataSearch: SchoolContent
}

struct SchoolContent: Codable {
    let content: [SchoolInfo]
}
