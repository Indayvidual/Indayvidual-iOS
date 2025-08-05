import SwiftUI
import Foundation

struct Category: Identifiable {
    let id = UUID()
    let categoryId : Int?
    let name: String
    let color: Color
}
