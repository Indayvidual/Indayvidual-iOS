import Foundation

struct ApiResponseHabitSliceResponseDTO: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let data: HabitSliceResponseDTO
}
