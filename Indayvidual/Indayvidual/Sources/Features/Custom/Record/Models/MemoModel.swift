//
//  MemoModel.swift
//  Indayvidual
//
//  Created by 김도연 on 7/19/25.
//

import SwiftUI

struct MemoModel: Codable, Identifiable {
    var id = UUID()
    var title: String
//    var contentPreview: String
//    var createdAt: String
//    var updatedAt: String
//    
//    var memoId: Int
    var content: String
    var date: String
    var time: String
//    
//    enum CodingKeys: String, CodingKey {
//        case date       = "createdData"
//        case time       = "createdTime"
//    }
}
