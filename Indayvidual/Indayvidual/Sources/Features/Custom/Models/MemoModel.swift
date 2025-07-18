//
//  MemoModel.swift
//  Indayvidual
//
//  Created by 김도연 on 7/19/25.
//

import SwiftUI

struct MemoModel: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var content: String
    var date: String
    var time: String
}
