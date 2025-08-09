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
                    do {
                        let apiResponse = try JSONDecoder().decode(ApiResponseMemoDetailResponseDTO.self, from: response.data)
                        let updated = apiResponse.data.toModel()
                        DispatchQueue.main.async {
                            self.sharedVM.memos.remove(at: idx)
                            self.sharedVM.memos.insert(updated, at: 0)
                            print("✅ PATCH 성공")
                        }
                    } catch {
                        print("❌ PATCH decoding 실패:", error)
                        _ = String(data: response.data, encoding: .utf8)
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
                    do {
                        let api = try JSONDecoder().decode(ApiResponseMemoDetailResponseDTO.self, from: response.data)
                        let newMemo = api.data.toModel()
                        DispatchQueue.main.async {
                            self.sharedVM.memos.insert(newMemo, at: 0)
                            print("✅ POST 성공")
                        }
                    } catch {
                        print("❌ POST decoding 실패:", error)
                        _ = String(data: response.data, encoding: .utf8)
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
                    print("✅ DELETE 성공 (memoId: \(memoId))")
                }
            case .failure(let error):
                print("❌ DELETE 요청 실패:", error)
            }
        }
    }
}
