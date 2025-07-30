import Foundation

struct ApiResponseHabitResponseDTO: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let data: HabitResponseDTO
}
