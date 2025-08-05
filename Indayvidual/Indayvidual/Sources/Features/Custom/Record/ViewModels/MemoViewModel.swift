//
//  MemoViewModel.swift
//  Indayvidual
//
//  Created by 김도연 on 7/18/25.
//

import Foundation
import Observation
import Moya

@Observable
class MemoViewModel {
    var title: String
    var content: String

    let isEditing: Bool
    let editIndex: Int?

    private let sharedVM: CustomViewModel
    private let provider = MoyaProvider<MemoAPITarget>()

    init(sharedVM: CustomViewModel, memo: MemoModel? = nil, index: Int? = nil) {
        self.sharedVM = sharedVM
        if let memo = memo, let idx = index {
            self.title = memo.title
            self.content = memo.content
            self.editIndex = idx
            self.isEditing = true
        } else {
            self.title = ""
            self.content = ""
            self.editIndex = nil
            self.isEditing = false
        }
    }

    func save() {
        let newTitle = title.isEmpty ? "새로운 메모" : title

        if let idx = editIndex {
            // 수정 요청
            guard let memoId = sharedVM.memos[idx].memoId else {
                print("❌ memoId 없음")
                return
            }

            provider.request(.patchMemos(memoId: memoId, title: newTitle, content: content)) { result in
                switch result {
                case .success(let response):
                    if response.statusCode == 204 {
                        print("✅ PATCH 성공 (204 No Content)")
                        DispatchQueue.main.async {
                            var memo = self.sharedVM.memos[idx]
                            memo.title = newTitle
                            memo.content = self.content
                            self.sharedVM.memos.remove(at: idx)
                            self.sharedVM.memos.insert(memo, at: 0)
                        }
                        return
                    }

                    // 예외적으로 JSON이 온다면 처리
                    do {
                        let apiResponse = try JSONDecoder().decode(ApiResponseMemoDetailResponseDTO.self, from: response.data)
                        let updated = apiResponse.data.toModel()
                        DispatchQueue.main.async {
                            self.sharedVM.memos.remove(at: idx)
                            self.sharedVM.memos.insert(updated, at: 0)
                        }
                    } catch {
                        print("❌ PATCH decoding 실패:", error)
                    }

                case .failure(let error):
                    print("❌ PATCH 요청 실패:", error)
                }
            }

        } else {
            // 생성 요청
            provider.request(.postMemos(title: newTitle, content: content)) { result in
                switch result {
                case .success(let response):
                    if response.statusCode == 204 || response.data.isEmpty {
                        print("✅ POST 성공 (204 No Content)")
                        DispatchQueue.main.async {
                            let now = Date()
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyMMdd"
                            let timeFormatter = DateFormatter()
                            timeFormatter.dateFormat = "HH:mm"
                            
                            let newMemo = MemoModel(
                                id: UUID(),
                                memoId: nil,  // 서버가 memoId를 안 줬으니까 nil 처리
                                title: newTitle,
                                content: self.content,
                                date: dateFormatter.string(from: now),
                                time: timeFormatter.string(from: now)
                            )
                            self.sharedVM.memos.insert(newMemo, at: 0)
                        }
                        return
                    }

                    // 예외적으로 JSON이 온 경우만 처리
                    do {
                        let api = try JSONDecoder().decode(ApiResponseMemoDetailResponseDTO.self, from: response.data)
                        let newMemo = api.data.toModel()
                        DispatchQueue.main.async {
                            self.sharedVM.memos.insert(newMemo, at: 0)
                        }
                    } catch {
                        print("❌ POST decoding 실패:", error)
                        let raw = String(data: response.data, encoding: .utf8)
                        print("🧾 응답 본문:", raw ?? "없음")
                    }

                case .failure(let error):
                    print("❌ POST 요청 실패:", error)
                }
            }
        }
    }

    func delete(at index: Int) {
        guard let memoId = sharedVM.memos[index].memoId else {
            print("❌ memoId 없음")
            return
        }

        provider.request(.deleteMemos(memoId: memoId)) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.sharedVM.memos.remove(at: index)
                }
            case .failure(let error):
                print("DELETE 요청 실패:", error)
            }
        }
    }
}
