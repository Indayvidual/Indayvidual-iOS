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
                        let wrapper = try JSONDecoder()
                            .decode(ApiResponseHabitResponseDTO.self, from: response.data)
                        let newHabit = wrapper.data.toModel()
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
    func toggleSelection(at index: Int, date: String) {
        guard index < sharedVM.habits.count,
              let habitId = sharedVM.habits[index].habitId else { return }
        
        // 이전 상태 저장
        let oldChecked = sharedVM.habits[index].isSelected
        let newChecked = !oldChecked
        
        provider.request(
            .patchHabitsCheck(habitId: habitId, date: date, checked: newChecked)
        ) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    // 상태 업데이트
                    self.sharedVM.habits[index].isSelected = newChecked
                    self.sharedVM.habits[index].checkedAt  = newChecked ? date : ""
                }
            case .failure(let err):
                print("❌ 토글 실패:", err)
            }
        }
    }
    
    
    // ✅ 일간 체크 불러오기
    func fetchDailyChecks(Date: String) {
        provider.request(.getHabitsCheckDaily(Date: Date)) { result in
            switch result {
            case .success(let response):
                do {
                    let wrapper = try JSONDecoder()
                        .decode(ApiResponseListHabitResponseDTO.self, from: response.data)
                    
                    let checkMap = Dictionary(uniqueKeysWithValues:
                        wrapper.data.map { ($0.habitId, ($0.checked, $0.checkedAt ?? "")) }
                    )
                    
                    DispatchQueue.main.async {
                        self.sharedVM.habits = self.sharedVM.habits.map {
                            var h = $0
                            if let id = h.habitId, let (checked, date) = checkMap[id] {
                                h.isSelected = checked
                                h.checkedAt = date
                            } else {
                                h.isSelected = false
                                h.checkedAt = ""
                            }
                            return h
                        }
                    }
                } catch {
                    print("❌ 일간 체크 디코딩 실패: \(error)")
                }
                
            case .failure(let error):
                print("❌ 일간 체크 API 실패: \(error)")
            }
        }
    }
}
