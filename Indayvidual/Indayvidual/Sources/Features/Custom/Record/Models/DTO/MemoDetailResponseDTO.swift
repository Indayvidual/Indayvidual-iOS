import Foundation

struct MemoDetailResponseDTO: Codable {
    let memoId: Int
    let content: String
    let createdDate: String
    let createdTime: LocalTime
}

struct LocalTime: Codable {
    let hour: Int
    let minute: Int
    let second: Int
    let nano: Int
}

extension MemoDetailResponseDTO {
    func toModel() -> MemoModel {
        return MemoModel(
            id: UUID(), // Or map from memoId if you want Int
            memoId: memoId,
            title: "",  // Title not present in this DTO
            content: content,
            date: createdDate,
            time: String(format: "%02d:%02d", createdTime.hour, createdTime.minute)
        )
    }
}
