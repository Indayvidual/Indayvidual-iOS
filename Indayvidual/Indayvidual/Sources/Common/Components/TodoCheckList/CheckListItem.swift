import Foundation
struct CheckListItem: Identifiable {
    let id = UUID()
    var text: String
    var isChecked: Bool
}
