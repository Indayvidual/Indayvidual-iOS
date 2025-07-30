//
//  MemoViewModel.swift
//  Indayvidual
//
//  Created by 김도연 on 7/18/25.
//
import Foundation
import Observation

@Observable
class MemoViewModel {
    // MARK: - 입력 필드
    var title: String
    var content: String
    
    // MARK: - 모드 구분
    let isEditing: Bool
    let editIndex: Int?   // 수정 시, sharedVM.memos 에서의 인덱스
    
    // MARK: - 공유 뷰모델 참조
    private let sharedVM: CustomViewModel
    
    init(sharedVM: CustomViewModel, memo: MemoModel? = nil, index: Int? = nil) {
        self.sharedVM = sharedVM
        if let memo = memo, let idx = index {
            // 수정 모드
            self.title = memo.title
            self.content = memo.content
            self.editIndex = idx
            self.isEditing = true
        } else {
            // 신규 작성 모드
            self.title = ""
            self.content = ""
            self.editIndex = nil
            self.isEditing = false
        }
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMdd"
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    func save() {
        let newTitle = title.isEmpty ? "새로운 메모" : title
        // 현재 시간으로 날짜, 시간 생성
        let now = Date()
        let dateString = Self.dateFormatter.string(from: now)
        let timeString = Self.timeFormatter.string(from: now)
        
        if let idx = editIndex {
            // 수정 모드: 기존 항목을 제거하고 업데이트된 항목을 맨 앞에 삽입
            let existingMemo = sharedVM.memos.remove(at: idx)
            let updated = MemoModel(
                id: existingMemo.id,
                title: title,
                content: content,
                date: dateString,
                time: timeString
            )
            sharedVM.memos.insert(updated, at: 0)
        } else {
            // 신규 모드: 배열 맨 앞에 삽입
            let newMemo = MemoModel(
                id: UUID(),
                title: newTitle,
                content: content,
                date: dateString,
                time: timeString
            )
            sharedVM.memos.insert(newMemo, at: 0)
        }
    }
    
    func delete(at index: Int) {
        sharedVM.memos.remove(at: index)
    }
}
