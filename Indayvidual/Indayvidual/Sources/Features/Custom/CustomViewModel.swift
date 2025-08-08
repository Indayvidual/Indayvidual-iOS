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

    private let memoProvider = MoyaProvider<MemoAPITarget>()
    private let habitProvider = MoyaProvider<HabitAPITarget>()

    init() {
        loadMemos()
        loadHabits()
    }

    // ✅ 메모 불러오기
    func loadMemos() {
        memoProvider.request(.getMemos) { result in
            switch result {
            case .success(let response):
                print("📦 [Memos] 상태 코드:", response.statusCode)
                print("📦 [Memos] 응답 원문:", String(data: response.data, encoding: .utf8) ?? "없음")

                guard !response.data.isEmpty else {
                    print("✅ 메모 응답이 비어 있음")
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(ApiResponseMemoSliceResponseDTO.self, from: response.data)
                    let models = decoded.data.toModelList()
                    DispatchQueue.main.async {
                        self.memos = models
                        print("✅ 메모 불러오기 성공")
                    }
                } catch {
                    print("❌ 메모 디코딩 실패:", error)
                }

            case .failure(let error):
                print("❌ 메모 API 요청 실패:", error)
            }
        }
    }

    // ✅ 습관 불러오기
    func loadHabits() {
        habitProvider.request(.getHabits) { result in
            switch result {
            case .success(let response):
                print("📦 [Habits] 상태 코드:", response.statusCode)
                print("📦 [Habits] 응답 원문:", String(data: response.data, encoding: .utf8) ?? "없음")

                guard !response.data.isEmpty else {
                    print("✅ 습관 응답이 비어 있음")
                    return
                }

                do {
                    let slice = try JSONDecoder()
                        .decode(ApiResponseHabitSliceResponseDTO.self, from: response.data)
                    let models = slice.data.toModelList()
                    
                    DispatchQueue.main.async {
                        self.habits = models
                        print("✅ 습관 슬라이스 불러오기 성공: \(models.count)개")
                    }

                } catch {
                    print("❌ 습관 디코딩 실패:", error)
                }

            case .failure(let error):
                print("❌ 습관 API 요청 실패:", error)
            }
        }
    }
}
