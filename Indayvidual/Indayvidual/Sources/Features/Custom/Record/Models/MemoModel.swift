import SwiftUI

struct MemoModel: Codable, Identifiable {
    var id = UUID()
    var memoId: Int?
    var title: String
    var content: String
    var date: String
    var time: String
}

extension MemoModel {
    func toCreateDTO() -> CreateMemoRequestDTO {
        return CreateMemoRequestDTO(title: title, content: content)
    }

    func toUpdateDTO() -> UpdateMemoRequestDTO {
        return UpdateMemoRequestDTO(title: title, content: content)
    }
}
