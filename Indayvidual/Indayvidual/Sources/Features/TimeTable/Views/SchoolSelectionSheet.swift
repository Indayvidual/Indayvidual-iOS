//
//  SchoolSelectionSheet.swift
//  Indayvidual
//
//  Created by 장주리 on 7/23/25.
//

import SwiftUI

public struct SchoolSelectionSheet: View {
    @Binding var showSemesterSheet: Bool
    @Binding var selectedSchoolName: String?

    @StateObject private var viewModel = SchoolInfoViewModel()
    @State private var selectedSchool: SchoolInfo? = nil
    @State private var searchText: String = ""
    @Environment(\.dismiss) private var dismiss

    public init(showSemesterSheet: Binding<Bool>, selectedSchoolName: Binding<String?>) {
        self._showSemesterSheet = showSemesterSheet
        self._selectedSchoolName = selectedSchoolName
    }

    public var body: some View {
        CustomActionSheet(
            title: "학교 설정",
            primaryButtonTitle: "학교 설정 완료",
            primaryAction: {
                guard let school = selectedSchool else { return }
                selectedSchoolName = school.name
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showSemesterSheet = true
                }
            },
            secondaryAction: {
                dismiss()
            },
            showDivider: false
        ) {
            VStack(alignment: .leading, spacing: 0) {
                searchBar
                Spacer().frame(height: 24)
                Divider().foregroundStyle(Color(.gray200))
                schoolList
            }
            .padding(.horizontal, 20)
            .task {
                viewModel.loadAllSchools(searchTxt: "")
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            TextField("학교 이름 검색", text: $searchText)
                .font(.pretendMedium14)
                .foregroundColor(.black)
                .disableAutocorrection(true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onChange(of: searchText) { newValue in
                    viewModel.search(with: newValue)
                }

            Image("Group")
                .resizable()
                .frame(width: 15, height: 15)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .frame(height: 48)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .inset(by: 0.5)
                .stroke(Color(red: 0.84, green: 0.85, blue: 0.86), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private var schoolList: some View {
        if viewModel.isLoading {
            ProgressView("학교를 검색하는 중...")
        } else if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .foregroundColor(viewModel.schoolNames.isEmpty ? .gray : .red)
        } else {
            List(viewModel.schoolNames) { school in
                SchoolRow(school: school, selectedSchool: $selectedSchool)
            }
            .listStyle(.plain)
        }
    }
}

private struct SchoolRow: View {
    let school: SchoolInfo
    @Binding var selectedSchool: SchoolInfo?

    var isSelected: Bool {
        selectedSchool?.id == school.id
    }

    var body: some View {
        HStack(spacing: 10) {
            Button(action: { selectedSchool = school }) {
                Image(isSelected ? "ic_24_bell_fill" : "ic_24_bell")
            }

            Text(school.name)
                .font(.pretendMedium14)
                .foregroundStyle(Color(.gray900))
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedSchool = school
        }
    }
}

struct SchoolSelectionSheet_Previews: PreviewProvider {
    @State static var showSemesterSheet = false
    @State static var selectedSchoolName: String? = nil

    static var previews: some View {
        SchoolSelectionSheet(
            showSemesterSheet: $showSemesterSheet,
            selectedSchoolName: $selectedSchoolName
        )
    }
}
