import Foundation

struct MemoSummaryResponseDTO: Codable {
    let id: Int
    let title: String
    let contentPreview: String
    let createdAt: String
    let updatedAt: String
}

extension MemoSummaryResponseDTO {
    func toModel() -> MemoModel {
        return MemoModel(
            id: UUID(), // Or map from id
            memoId: id,
            title: title,
            content: contentPreview,
            date: createdAt,
            time: ""
        )
    }
}
