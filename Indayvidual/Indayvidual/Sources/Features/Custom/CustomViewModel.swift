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
    var userSession: UserSession
    
    var name: String {
        return userSession.nickname
    }
    
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
    
    init(userSession: UserSession) {
        self.userSession = userSession
        
        loadMemos()
        loadHabits()
        loadWeeklyChecks()
    }
    
    // ✅ 메모 불러오기
    func loadMemos() {
        memoProvider.request(.getMemos) { result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(ApiResponseMemoSliceResponseDTO.self, from: response.data)
                    let models = decoded.data.toModelList()
                    let sorted = models.sorted {
                        if $0.date != $1.date {
                            return $0.date > $1.date      // "yyMMdd" 최신이 먼저
                        }
                        return $0.time > $1.time          // 같은 날이면 "HH:mm" 최신이 먼저
                    }
                    DispatchQueue.main.async {
                        self.memos = sorted
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
    
    // ✅ 일주일 습관 체크 내역 불러오기
    func loadWeeklyChecks() {
        // Gregorian 캘린더, 일요일이 주 시작
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.firstWeekday = 1 // 1 = Sunday

        let today = Date()
        
        // 이번 주 일요일 찾기
        let weekday = gregorian.component(.weekday, from: today)
        let daysFromSunday = weekday - 1
        guard let sunday = gregorian.date(byAdding: .day, value: -daysFromSunday, to: today) else {
            print("⚠️ 이번 주 일요일 계산 실패")
            return
        }
        
        let startDate = sunday.toAPIDateFormat()
        
        habitProvider.request(.getHabitsCheckWeekly(startDate: startDate)) { result in
            switch result {
            case .success(let response):
                do {
                    let wrapper = try JSONDecoder()
                        .decode(ApiResponseListHabitWeeklyChecksResponseDTO.self, from: response.data)
                    
                    let models = wrapper.data.map { dto -> MyHabitModel in
                        // 일~토 날짜 배열
                        let weekDates: [String] = (0..<7).map { offset in
                            gregorian
                                .date(byAdding: .day, value: offset, to: sunday)!
                                .toAPIDateFormat()
                        }
                        let checkMap = Dictionary(uniqueKeysWithValues:
                            dto.checkedAtList.map { ($0.checkedAt, $0.isChecked) }
                        )
                        let checks = weekDates.map { checkMap[$0] ?? false }
                        return MyHabitModel(
                            habitId:    dto.habitId,
                            title:      dto.title,
                            colorName:  dto.colorCode,
                            checkedAt:  "",
                            isSelected: false,
                            checks:     checks
                        )
                    }
                    
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
