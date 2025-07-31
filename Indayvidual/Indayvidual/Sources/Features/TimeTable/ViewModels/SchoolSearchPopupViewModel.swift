//
//  SchoolSearchPopupViewModel.swift
//  Indayvidual
//
//  Created by 장주리 on 7/31/25.
//

import Foundation
import SwiftUI

class SchoolSearchPopupViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchPerformed: Bool = false
    @Published var selectedSchool: SchoolInfo? = nil

    var isSaveButtonEnabled: Bool {
        selectedSchool != nil
    }

    func handleSearchTextChange(newValue: String, schoolInfoViewModel: SchoolInfoViewModel) {
        if newValue.isEmpty {
            searchPerformed = false
            schoolInfoViewModel.schoolNames = []
        } else {
            searchPerformed = true
            schoolInfoViewModel.search(with: newValue)
        }
    }

    func saveSelection() -> String? {
        selectedSchool?.name
    }
}
