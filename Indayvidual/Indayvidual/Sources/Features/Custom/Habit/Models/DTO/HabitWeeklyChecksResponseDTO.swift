import Foundation

struct HabitWeeklyChecksResponseDTO: Codable {
    let habitId: Int
    let title: String
    let colorCode: String
    let checkedAtList: [HabitDateChecksResponseDTO]
}

extension HabitWeeklyChecksResponseDTO {
    func toWeeklyModel() -> MyHabitModel {
        let checkFlags = checkedAtList.map { $0.isChecked }
        return MyHabitModel(
            habitId: habitId,
            title: title,
            colorName: colorCode,
            checkedAt: "", // 필요 없다면 빈 문자열
            isSelected: false,
            checks: checkFlags
        )
    }
}
