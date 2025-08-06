//
//  MyHabitViewModel.swift
//  Indayvidual
//
//  Created by 김도연 on 7/23/25.
//

import Foundation
import SwiftUI
import Moya

@Observable
class MyHabitViewModel {
    var title: String
    var colorName: String
    
    let isEditing: Bool
    let editIndex: Int?
    
    private let sharedVM: CustomViewModel
    private let provider = MoyaProvider<HabitAPITarget>()
    
    init(sharedVM: CustomViewModel, habit: MyHabitModel? = nil, index: Int? = nil) {
        self.sharedVM = sharedVM
        if let habit = habit, let idx = index {
            self.title = habit.title
            self.colorName = habit.colorName
            self.editIndex = idx
            self.isEditing = true
        } else {
            self.title = ""
            self.colorName = "purple-05"
            self.editIndex = nil
            self.isEditing = false
        }
    }
    
    // ✅ 습관 저장 (신규 or 수정)
    func save() {
        let nowTitle = title.isEmpty ? "습관 이름" : title
        let dto = CreateHabitRequestDTO(title: nowTitle, colorCode: colorName)
        
        if let idx = editIndex,
           let habitId = sharedVM.habits[idx].habitId {
            let updateDTO = UpdateHabitRequestDTO(title: nowTitle, colorCode: colorName)
            provider.request(.patchHabits(habitId: habitId, title: updateDTO.title, colorCode: updateDTO.colorCode)) { result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        var updated = self.sharedVM.habits[idx]
                        updated.title = self.title
                        updated.colorName = self.colorName
                        self.sharedVM.habits.remove(at: idx)
                        self.sharedVM.habits.insert(updated, at: 0)
                        print("✅ 습관 수정 성공")
                    }
                case .failure(let error):
                    print("❌ PATCH 실패: \(error)")
                }
            }
        } else {
            provider.request(.postHabits(title: dto.title, colorCode: dto.colorCode)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try JSONDecoder().decode(HabitResponseDTO.self, from: response.data)
                        let newHabit = decoded.toModel()
                        DispatchQueue.main.async {
                            self.sharedVM.habits.insert(newHabit, at: 0)
                            print("✅ 습관 생성 성공")
                        }
                    } catch {
                        print("❌ 생성 디코딩 실패: \(error)")
                    }
                case .failure(let error):
                    print("❌ POST 실패: \(error)")
                }
            }
        }
    }
    
    // ✅ 습관 삭제
    func delete(at index: Int) {
        guard index < sharedVM.habits.count,
              let habitId = sharedVM.habits[index].habitId else {
            print("❌ 삭제할 habitId 없음")
            return
        }
        
        provider.request(.deleteHabits(habitId: habitId)) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.sharedVM.habits.remove(at: index)
                    print("✅ 습관 삭제 성공 (habitId: \(habitId))")
                }
            case .failure(let error):
                print("❌ DELETE 실패: \(error)")
            }
        }
    }

    // ✅ 체크 상태 토글 (선택/해제)
    func toggleSelection(at index: Int) {
        guard index < sharedVM.habits.count,
              let habitId = sharedVM.habits[index].habitId else {
            print("❌ 체크할 habitId 없음")
            return
        }

        let current = sharedVM.habits[index]
        let newChecked = !current.isSelected
        let date = current.checkedAt

        provider.request(.patchHabitsCheck(habitId: habitId, date: date, checked: newChecked)) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.sharedVM.habits[index].isSelected = newChecked
                    print("✅ 체크 상태 변경 성공 - habitId: \(habitId), 날짜: \(date), 상태: \(newChecked ? "체크됨 ✅" : "해제됨 ❌")")
                }
            case .failure(let error):
                print("❌ 체크 토글 실패: \(error)")
            }
        }
    }
    
    // ✅ 일간 체크 불러오기
    func fetchDailyChecks(startDate: String) {
        provider.request(.getHabitsCheckDaily(startDate: startDate)) { result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode([HabitResponseDTO].self, from: response.data)
                    let habits = decoded.map { $0.toModel() }
                    DispatchQueue.main.async {
                        self.sharedVM.habits = habits
                        print("✅ 일간 체크 불러오기 성공")
                    }
                } catch {
                    print("❌ 일간 체크 디코딩 실패: \(error)")
                }
            case .failure(let error):
                print("❌ 일간 체크 API 실패: \(error)")
            }
        }
    }

    // ✅ 주간 체크 불러오기
    func fetchWeeklyChecks(startDate: String) {
        provider.request(.getHabitsCheckWeekly(startDate: startDate)) { result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode([HabitWeeklyChecksResponseDTO].self, from: response.data)
                    let habits = decoded.map { $0.toWeeklyModel() }
                    DispatchQueue.main.async {
                        self.sharedVM.habits = habits
                        print("✅ 주간 체크 불러오기 성공")
                    }
                } catch {
                    print("❌ 주간 체크 디코딩 실패: \(error)")
                }
            case .failure(let error):
                print("❌ 주간 체크 API 실패: \(error)")
            }
        }
    }

    // ✅ 월간 체크 불러오기
    func fetchMonthlyChecks(startDate: String) {
        provider.request(.getHabitsCheckMonthly(startDate: startDate)) { result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode([HabitMonthlyChecksResponseDTO].self, from: response.data)
                    let all = decoded.flatMap { $0.toModelList() }
                    DispatchQueue.main.async {
                        self.sharedVM.habits = all
                        print("✅ 월간 체크 불러오기 성공")
                    }
                } catch {
                    print("❌ 월간 체크 디코딩 실패: \(error)")
                }
            case .failure(let error):
                print("❌ 월간 체크 API 실패: \(error)")
            }
        }
    }
}
