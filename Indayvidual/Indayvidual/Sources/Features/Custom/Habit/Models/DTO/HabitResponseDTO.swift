import Foundation

// MARK: – 개별 DTO
struct HabitResponseDTO: Codable {
    let habitId: Int
    let title: String
    let colorCode: String
    let checkedAt: String?   // null 허용
    let checked: Bool

    /// 단일 HabitResponseDTO → MyHabitModel 로 매핑
    func toModel() -> MyHabitModel {
        MyHabitModel(
            habitId: habitId,
            title: title,
            colorName: colorCode,
            checkedAt: checkedAt ?? "",
            isSelected: checked
        )
    }
}

// MARK: – 단일 응답 래퍼
struct ApiResponseHabitResponseDTO: Codable {
    let isSuccess: Bool?
    let code: String
    let message: String
    let data: HabitResponseDTO

    /// HabitResponseDTO → MyHabitModel 로 바로 매핑
    func toModel() -> MyHabitModel {
        return data.toModel()
    }
}

// MARK: – 리스트 응답 래퍼
struct ApiResponseListHabitResponseDTO: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let data: [HabitResponseDTO]

    /// [HabitResponseDTO] → [MyHabitModel] 로 매핑
    func toModelList() -> [MyHabitModel] {
        data.map { $0.toModel() }
    }
}

struct ApiResponseHabitSingleDTO: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let data: HabitResponseDTO
}

extension Array where Element == HabitResponseDTO {
    func toModelList() -> [MyHabitModel] {
        return self.map { $0.toModel() }
    }
}
