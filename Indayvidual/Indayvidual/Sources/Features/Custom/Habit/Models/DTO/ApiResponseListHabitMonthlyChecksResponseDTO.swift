import Foundation

struct ApiResponseListHabitMonthlyChecksResponseDTO: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let data: [HabitMonthlyChecksResponseDTO]
}
