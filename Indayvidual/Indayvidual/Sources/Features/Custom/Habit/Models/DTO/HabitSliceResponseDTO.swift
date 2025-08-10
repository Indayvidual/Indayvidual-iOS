import Foundation

struct HabitSliceResponseDTO: Codable {
    let habits: [HabitResponseDTO]
    let hasNext: Bool
    let page: Int
    let size: Int
    let numberOfElements: Int
    let first: Bool
}

struct ApiResponseHabitSliceResponseDTO: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let data: HabitSliceResponseDTO
}

extension HabitSliceResponseDTO {
    func toModelList() -> [MyHabitModel] {
        return habits.map { $0.toModel() }
    }
}
