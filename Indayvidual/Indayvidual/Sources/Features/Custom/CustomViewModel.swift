//
//  CustomViewModel.swift
//  Indayvidual
//
//  Created by 김도연 on 7/6/25.
//

import Foundation
import SwiftUI
import Observation

@Observable
class CustomViewModel {
    var name: String = "홍길동"
    
    var memos: [MemoModel] = [
        MemoModel(title: "메모1", content: "긴 내용1\n내용1내용1내용1내용1내용1내용1내용1내용1내용1", date: "250718", time: "12:00"),
        MemoModel(title: "메모2", content: "내용2\n내용2", date: "250717", time: "13:00"),
        MemoModel(title: "메모3", content: "내용3\n내용3", date: "250717", time: "13:00"),
        MemoModel(title: "메모4", content: "내용4", date: "250717", time: "13:00"),
        MemoModel(title: "메모5", content: "내용5", date: "250717", time: "13:00"),
        MemoModel(title: "메모6", content: "내용6", date: "250717", time: "13:00"),
    ]
    
    var num: Int {
        memos.count
    }
    
    func deleteMemo(at index: Int) {
        memos.remove(at: index)
    }
}
