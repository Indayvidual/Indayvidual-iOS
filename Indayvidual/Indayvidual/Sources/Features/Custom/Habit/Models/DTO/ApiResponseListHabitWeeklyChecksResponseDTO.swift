import Foundation

struct ApiResponseListHabitWeeklyChecksResponseDTO: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let data: [HabitWeeklyChecksResponseDTO]
}
