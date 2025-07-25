//
//  TimeTableView.swift
//  Indayvidual
//
//  Created by 장주리 on 7/23/25.
//

import SwiftUI

struct TimeTableView: View {
    @State private var selection: String?
    @State private var showSchoolSheet = false
    @State private var showSemesterSheet = false

    @State private var selectedSchoolName: String?
    @State private var selectedSemester: String?
    
    @State private var dropdownOptions: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Topbar()
            Spacer().frame(height: 10)
            
            DropdownBar(
                hint: "미정",
                options: dropdownOptions,
                selection: $selection
            )
            .padding(.horizontal, 15)
            
            if dropdownOptions.isEmpty {
                        EmptyTimeTableView()
            }
                    
            
            Spacer()
        }
        .floatingBtn {
            showSchoolSheet = true
        }
        .sheet(isPresented: $showSchoolSheet) {
            SchoolSelectionSheet(
                showSemesterSheet: $showSemesterSheet,
                selectedSchoolName: $selectedSchoolName
            )
        }
        .sheet(isPresented: $showSemesterSheet, onDismiss: {
            if let school = selectedSchoolName, let semester = selectedSemester {
                let newEntry = "\(school) \(semester)"
                if !dropdownOptions.contains(newEntry) {
                    dropdownOptions.append(newEntry)
                    if selection == nil {
                        selection = newEntry
                        }
                }
            }
        }) {
            SemesterSelectionSheet(
                isPresented: $showSemesterSheet,
                selectedSemester: $selectedSemester
            )
            .presentationDragIndicator(.visible)
            .presentationDetents([.height(350)])
        }
        .background(Color(.gray50))
    }
}

#Preview {
    TimeTableView()
}
