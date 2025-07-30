import Foundation

struct HabitWeeklyChecksResponseDTO: Codable {
    let habitId: Int
    let title: String
    let colorCode: String
    let checkedAtList: [HabitDateChecksResponseDTO]
}

extension HabitWeeklyChecksResponseDTO {
    func toModelList() -> [MyHabitModel] {
        return checkedAtList.map { check in
            MyHabitModel(
                habitId: habitId,
                title: title,
                colorName: colorCode,
                checkedAt: check.checkedAt,
                isSelected: check.isChecked
            )
        }
    }
}
