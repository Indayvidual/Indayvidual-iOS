import Foundation

struct MemoDetailResponseDTO: Codable {
    let memoId: Int
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
        // "09:35:59.34483839" 형태에서 "09:35"만 추출
        let timeComponents = createdTime.split(separator: ":")
        let hour = timeComponents.indices.contains(0) ? String(timeComponents[0]) : "00"
        let minute = timeComponents.indices.contains(1) ? String(timeComponents[1]) : "00"
        let formattedTime = "\(hour):\(minute)"
        
        return MemoModel(
            id: UUID(),
            memoId: memoId,
            title: "",  // DTO에 title이 없다면 빈 문자열로
            content: content,
            date: createdDate,
            time: formattedTime
        )
    }
}
