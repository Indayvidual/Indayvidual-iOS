//
//  CustomViewModel.swift
//  Indayvidual
//
//  Created by 김도연 on 7/6/25.
//

import Foundation
import Moya
import SwiftUI
import Observation

@Observable
class CustomViewModel {
    var name: String = "인데비"

    // MARK: - 메모
    var memos: [MemoModel] = []

    var memosCount: Int {
        memos.count
    }

    // MARK: - 습관
    var habits: [MyHabitModel] = []

    var habitsSelectedCount: Int {
        habits.filter { $0.isSelected }.count
    }

    private let provider = MoyaProvider<MemoAPITarget>()

    init() {
        loadMemos() // 앱 실행 시 자동 호출
    }

    func loadMemos() {
        provider.request(.getMemos) { result in
            switch result {
            case .success(let response):
                print("📦 상태 코드:", response.statusCode)
                print("📦 응답 원문:", String(data: response.data, encoding: .utf8) ?? "없음")

                guard !response.data.isEmpty else {
                    print("✅ 응답이 비어 있음 (204 No Content 등)")
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(ApiResponseMemoSliceResponseDTO.self, from: response.data)
                    let models = decoded.data.toModelList()
                    DispatchQueue.main.async {
                        self.memos = models
                    }
                } catch {
                    print("❌ 디코딩 실패:", error)
                }

            case .failure(let error):
                print("❌ API 요청 실패:", error)
            }
        }
    }
}
