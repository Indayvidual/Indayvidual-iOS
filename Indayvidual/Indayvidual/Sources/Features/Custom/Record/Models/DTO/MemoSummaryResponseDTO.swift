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
            id: UUID(),
            memoId: id,
            title: title,
            content: contentPreview,
            date: updatedAt.asYYMMDD(),
            time: updatedAt.asHHmm()
        )
    }
}
