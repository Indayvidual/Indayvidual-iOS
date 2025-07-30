import Foundation

struct ApiResponseListHabitResponseDTO: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let data: [HabitResponseDTO]
}
