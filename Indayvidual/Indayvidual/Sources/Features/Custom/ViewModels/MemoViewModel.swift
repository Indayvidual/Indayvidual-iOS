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
    
    func save() {
        // 현재 시간으로 날짜, 시간 생성
        let now = Date()
        let df = DateFormatter()
        df.dateFormat = "yyMMdd"
        let tf = DateFormatter()
        tf.dateFormat = "HH:mm"
        let dateString = df.string(from: now)
        let timeString = tf.string(from: now)
        
        if let idx = editIndex {
            // 수정 모드: 배열에서 해당 인덱스 교체
            var updated = sharedVM.memos[idx]
            updated.title = title
            updated.content = content
            updated.date = dateString
            updated.time = timeString
            sharedVM.memos[idx] = updated
            
            // 1) 기존 위치에서 제거
            sharedVM.memos.remove(at: idx)
            // 2) 맨 앞에 삽입
            sharedVM.memos.insert(updated, at: 0)
        } else {
            // 신규 모드: 배열 맨 앞에 삽입
            let newMemo = MemoModel(
                title: title,
                content: content,
                date: dateString,
                time: timeString
            )
            sharedVM.memos.insert(newMemo, at: 0)
        }
    }
}
