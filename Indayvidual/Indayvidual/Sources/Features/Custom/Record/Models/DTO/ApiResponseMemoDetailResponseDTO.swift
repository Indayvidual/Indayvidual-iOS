import Foundation

struct ApiResponseMemoDetailResponseDTO: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let data: MemoDetailResponseDTO
}
