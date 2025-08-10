import Foundation

struct MemoDetailResponseDTO: Codable {
    let memoId: Int
    let title: String
    let content: String
    let createdDate: String
    let createdTime: String
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
            id: UUID(),
            memoId: memoId,
            title: title,
            content: content,
            date: createdDate.asYYMMDD(),
            time: createdDate.asHHmm()
        )
    }
}
