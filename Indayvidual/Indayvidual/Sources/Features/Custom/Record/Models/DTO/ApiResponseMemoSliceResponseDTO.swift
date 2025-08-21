import Foundation

struct ApiResponseMemoSliceResponseDTO: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let data: MemoSliceResponseDTO
}
