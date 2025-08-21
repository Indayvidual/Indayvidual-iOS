import Foundation

struct HabitMonthlyChecksResponseDTO: Codable {
    let habitId: Int
    let title: String
    let colorCode: String
    let checkedDates: [String]
}

extension HabitMonthlyChecksResponseDTO {
    func toModelList() -> [MyHabitModel] {
        return checkedDates.map { date in
            MyHabitModel(
                habitId: habitId,
                title: title,
                colorName: colorCode,
                checkedAt: date,
                isSelected: true
            )
        }
    }
}
