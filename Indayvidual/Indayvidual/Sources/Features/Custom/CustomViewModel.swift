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
    var weeklyHabits: [MyHabitModel] = []
    
    var habitsSelectedCount: Int {
        habits.filter { $0.isSelected }.count
    }
    
    private let memoProvider = MoyaProvider<MemoAPITarget>()
    private let habitProvider = MoyaProvider<HabitAPITarget>()
    
    init() {
        loadMemos()
        loadHabits()
        loadWeeklyChecks()
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
    
    func loadWeeklyChecks() {
        // ISO8601 캘린더로 월요일 구하기
        let isoCal  = Calendar(identifier: .iso8601)
        let today   = Date()
        guard let monday = isoCal.date(
            from: isoCal.dateComponents([.yearForWeekOfYear, .weekOfYear],
                                        from: today)
        ) else {
            print("⚠️ 이번 주 월요일 계산 실패")
            return
        }
        
        let startDate = monday.toAPIDateFormat()
        
        habitProvider.request(.getHabitsCheckWeekly(startDate: startDate)) { result in
            switch result {
            case .success(let response):
                print("🧾 주간 체크 응답:", String(data: response.data, encoding: .utf8) ?? "")
                do {
                    // 최상위 래퍼 DTO 디코딩
                    let wrapper = try JSONDecoder()
                        .decode(ApiResponseListHabitWeeklyChecksResponseDTO.self, from: response.data)
                    // API로부터 받은 체크 리스트 → [String:Bool] 맵
                    let models = wrapper.data.map { dto -> MyHabitModel in
                        // 월~일 7일치 날짜 문자열 배열
                        let weekDates: [String] = (0..<7).map { offset in
                            isoCal
                                .date(byAdding: .day, value: offset, to: monday)!
                                .toAPIDateFormat()
                        }
                        // { "2025-08-04":true, ... }
                        let checkMap = Dictionary(uniqueKeysWithValues:
                                                    dto.checkedAtList.map { ($0.checkedAt, $0.isChecked) }
                        )
                        // 7일치 Bool 배열 생성
                        let checks = weekDates.map { checkMap[$0] ?? false }
                        // MyHabitModel로 변환
                        return MyHabitModel(
                            habitId:    dto.habitId,
                            title:      dto.title,
                            colorName:  dto.colorCode,
                            checkedAt:  "",
                            isSelected: false,
                            checks:     checks
                        )
                    }
                    // UI 스레드에서 반영
                    DispatchQueue.main.async {
                        self.weeklyHabits = models
                    }
                } catch {
                    print("❌ 주간 체크 디코딩 실패:", error)
                }
            case .failure(let err):
                print("❌ 주간 체크 API 실패:", err)
            }
        }
    }
}
