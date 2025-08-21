import Foundation

struct MemoSliceResponseDTO: Codable {
    let content: [MemoSummaryResponseDTO]
    let hasNext: Bool
    let page: Int
    let size: Int
    let numberOfElements: Int
    let first: Bool
}

extension MemoSliceResponseDTO {
    func toModelList() -> [MemoModel] {
        return content.map { $0.toModel() }
    }
}
