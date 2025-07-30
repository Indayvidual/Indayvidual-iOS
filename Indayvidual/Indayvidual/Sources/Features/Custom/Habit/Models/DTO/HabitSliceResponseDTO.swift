import Foundation

struct HabitSliceResponseDTO: Codable {
    let habits: [HabitResponseDTO]
    let hasNext: Bool
    let page: Int
    let size: Int
    let numberOfElements: Int
    let first: Bool
}

extension HabitSliceResponseDTO {
    func toModelList() -> [MyHabitModel] {
        return habits.map { $0.toModel() }
    }
}
