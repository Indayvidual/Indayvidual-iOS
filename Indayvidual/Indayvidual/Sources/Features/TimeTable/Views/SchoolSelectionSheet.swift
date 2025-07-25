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
    @State private var showAlert = false
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
                if selectedSchool == nil {
                    showAlert = true // 학교가 선택되지 않았으면 알림 표시
                } else {
                    selectedSchoolName = selectedSchool?.name
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showSemesterSheet = true
                    }
                }
            },
            secondaryAction: {
                dismiss()
            },
            showDivider: false
        ) {
            VStack(alignment: .leading, spacing: 0) {
                searchBar
                    .padding(.vertical, 24)
                Divider().foregroundStyle(Color(.gray200))
                schoolList
            }
            .padding(.horizontal, 20)
            .task {
                viewModel.loadAllSchools(searchTxt: "")
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("알림"), message: Text("학교를 선택해주세요."), dismissButton: .default(Text("확인")))
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            TextField("학교 이름 검색", text: $searchText)
                .font(.pretendMedium14)
                .foregroundColor(.black)
                .disableAutocorrection(true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onChange(of: searchText) { oldvalue, newValue in
                    if newValue.isEmpty {
                        viewModel.loadAllSchools(searchTxt: "")
                    } else {
                        viewModel.search(with: newValue)
                    }
                }

            Image("Group")
                .resizable()
                .frame(width: 15, height: 15)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
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
            VStack {
                Spacer()
                ProgressView("학교를 검색하는 중...")
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = viewModel.errorMessage {
            VStack {
                Spacer()
                Text(errorMessage)  /// 검색 키워드 없을 경우 메세지 띄움               
                    .foregroundColor(viewModel.schoolNames.isEmpty ? .gray : .red)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List(viewModel.schoolNames) { school in
                SchoolRow(school: school, selectedSchool: $selectedSchool)
                    .listRowSeparator(.hidden)
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
        .padding(.vertical, 20)
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
