import Foundation

struct HabitResponseDTO: Codable {
    let habitId: Int
    let title: String
    let colorCode: String
    let checkedAt: String
    let checked: Bool
}

extension HabitResponseDTO {
    func toModel() -> MyHabitModel {
        return MyHabitModel(
            habitId: habitId,
            title: title,
            colorName: colorCode,
            checkedAt: checkedAt,
            isSelected: checked
        )
    }
}

extension Array where Element == HabitResponseDTO {
    func toModelList() -> [MyHabitModel] {
        return self.map { $0.toModel() }
    }
}
